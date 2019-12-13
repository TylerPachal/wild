defmodule Wild.ByteTest do
  use ExUnit.Case, async: true
  use PropCheck

  alias Wild.{Bash, Byte}

  describe "tokenize_subject" do
    test "works with printable characters" do
      assert 'tyler' == Byte.tokenize_subject(<<116, 121, 108, 101, 114>>)
    end

    test "works with non-printable characters" do
      assert [239, 191, 19] == Byte.tokenize_subject(<<239, 191, 19>>)
    end

    test "works with codepoints larger than 256" do
      assert [197, 130] == Byte.tokenize_subject("ł")
    end
  end

  describe "tokenize_pattern" do
    test "escapes special characters that are preceeded by a backslash (92)" do
      assert [42] == Byte.tokenize_pattern(<<92, 42>>)
    end

    test "passes special characters through literally when they are not escaped" do
      assert [{:special, 42}] == Byte.tokenize_pattern(<<42>>)
    end

    test "basic class" do
      assert [?a, class, ?d] = Byte.tokenize_pattern("a[bc]d")
      assert class == MapSet.new([?b, ?c])
    end

    test "class with special characters" do
      assert [MapSet.new([?-, ?], ?a, ?*])] == Byte.tokenize_pattern("[]a*-]")
    end

    test "class with range" do
      assert [MapSet.new([?a, ?b, ?c, ?d])] == Byte.tokenize_pattern("[a-d]")
    end

    test "literals, escaped special charcters, and a class" do
      input = ~S"a\*b[1-3]?\9"
      output = Byte.tokenize_pattern(input)

      assert [?a, ?*, ?b, class, {:special, ??}, ?\\, ?9] = output
      assert class == MapSet.new([?1, ?2, ?3])
    end
  end

  describe "match - unit tests" do
    test "literal match" do
      assert true == Byte.match?("foobar", "foobar")
    end

    test "single character wildcard" do
      assert true == Byte.match?("foobar", "fo?bar")
    end

    test "multiple character wildcard" do
      assert true == Byte.match?("foobar", "f*r")
    end

    test "class of literals" do
      assert true == Byte.match?("foobar", "fooba[rR]")
    end

    test "class with range" do
      assert true == Byte.match?("foobar", "fooba[a-zA-Z]")
    end

    # http://man7.org/linux/man-pages/man7/glob.7.html
    test "class containing closing bracket" do
      # A closing square bracket can be the first character in a class
      assert true == Byte.match?("abc]def", "abc[]0]def")
    end

    test "works with non-utf8 binaries" do
      assert true == Byte.match?(<<0, 1, 2>>, <<0, 1, ??>>)
    end

    test "question mark matches exactly one byte" do
      assert false == Byte.match?("", "?")
      assert false == Byte.match?("a", "??")
      assert true == Byte.match?("aa", "??")
      assert true == Byte.match?("aa", "a?")
      assert true == Byte.match?("ł", "??")
    end
  end

  describe "match - property tests" do
    property "star should always match anything" do
      forall input <- Generators.input() do
        assert true == Wild.match?(input, "*")
      end
    end

    property "question mark should always match strings that one characters long" do
      forall input <- Generators.string(1) do
        assert true == Wild.match?(input, "?")
      end
    end

    property "should act the same as bash implementation", numtests: 1_000 do
      forall {input, pattern} <- Generators.input_and_pattern() do
        assert Bash.match?(input, pattern) == Wild.match?(input, pattern)
      end
    end
  end
end
