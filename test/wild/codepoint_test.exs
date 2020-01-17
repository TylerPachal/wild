defmodule Wild.CodepointTest do
  use ExUnit.Case, async: true
  use PropCheck

  alias Wild.{Bash, Codepoint, Generators}

  describe "tokenize_subject" do
    test "works with printable characters" do
      assert ["t", "y", "l", "e", "r"] == Codepoint.tokenize_subject(<<116, 121, 108, 101, 114>>)
    end

    test "works with non-printable characters" do
      assert [<<239>>, <<191>>, <<19>>] == Codepoint.tokenize_subject(<<239, 191, 19>>)
    end

    test "works with codepoints larger than 256" do
      assert ["ł"] == Codepoint.tokenize_subject("ł")
    end
  end

  describe "tokenize_pattern" do
    test "escapes special characters that are preceeded by a backslash (92)" do
      assert {:ok, ["*"]} == Codepoint.tokenize_pattern(<<92, 42>>)
    end

    test "passes special characters through literally when they are not escaped" do
      assert {:ok, [{:special, "*"}]} == Codepoint.tokenize_pattern(<<42>>)
    end

    test "basic class" do
      assert {:ok, ["a", class, "d"]} = Codepoint.tokenize_pattern("a[bc]d")
      assert class == MapSet.new(["b", "c"])
    end

    test "class with special characters" do
      assert {:ok, [MapSet.new(["-", "]", "a", "*"])]} == Codepoint.tokenize_pattern("[]a*-]")
    end

    test "class with range" do
      assert {:ok, [MapSet.new(["a", "b", "c", "d"])]} == Codepoint.tokenize_pattern("[a-d]")
    end

    test "literals, escaped special charcters, and a class" do
      subject = ~S"a\*b[1-3]?9"
      {:ok, output} = Codepoint.tokenize_pattern(subject)

      assert ["a", "*", "b", class, {:special, "?"}, "9"] = output
      assert class == MapSet.new(["1", "2", "3"])
    end

    test "keeps order of incomplete classes (which get turned to literals)" do
      assert {:ok, ["a", "[", "b", "c"]} == Codepoint.tokenize_pattern("a[bc")
    end

    test "returns error for invalid escape sequence" do
      assert {:error, :invalid_escape_sequence} == Codepoint.tokenize_pattern("\\")
    end

    test "returns error for invalid class" do
      assert {:error, :invalid_class} == Codepoint.tokenize_pattern("[!]")
    end
  end

  describe "match - unit tests" do
    test "literal match" do
      assert true == Codepoint.match?("foobar", "foobar")
    end

    test "single character wildcard" do
      assert true == Codepoint.match?("foobar", "fo?bar")
    end

    test "multiple character wildcard" do
      assert true == Codepoint.match?("foobar", "f*r")
    end

    test "class of literals" do
      assert true == Codepoint.match?("foobar", "fooba[rR]")
    end

    test "class with range" do
      assert true == Codepoint.match?("foobar", "fooba[a-zA-Z]")
    end

    test "empty class is treated literally" do
      assert true == Codepoint.match?("[]", "[]")
    end

    # http://man7.org/linux/man-pages/man7/glob.7.html
    test "class containing closing bracket" do
      # A closing square bracket can be the first character in a class
      assert true == Codepoint.match?("abc]def", "abc[]0]def")
    end

    test "works with non-utf8 binaries" do
      assert true == Codepoint.match?(<<0, 1, 2>>, <<0, 1, ??>>)
    end

    test "question mark matches exactly one Codepoint" do
      assert false == Codepoint.match?("", "?")
      assert false == Codepoint.match?("a", "??")
      assert true == Codepoint.match?("aa", "??")
      assert true == Codepoint.match?("aa", "a?")
      assert true == Codepoint.match?("ł", "?")
    end

    test "escaping is respected in the pattern" do
      assert true == Codepoint.match?("\\", "\\\\")
    end
  end

  describe "match - property tests" do
    property "star should always match anything" do
      forall subject <- Generators.subject() do
        assert true == Codepoint.match?(subject, "*")
      end
    end

    property "question mark should always match strings that one characters long" do
      forall subject <- Generators.string(1) do
        assert true == Codepoint.match?(subject, "?")
      end
    end

    property "should act the same as bash implementation" do
      forall {subject, pattern} <- Generators.codepoint_subject_and_pattern() do
        assert Bash.match?(subject, pattern) == Codepoint.match?(subject, pattern)
      end
    end
  end
end
