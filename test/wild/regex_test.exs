defmodule Wild.RegexTest do
  use ExUnit.Case, async: true
  use PropCheck

  alias Wild.{Bash, Regex, Generators}

  describe "compile_pattern" do
    test ":codepoint" do
      assert {:ok, ~r/^abc$/su} == Regex.compile_pattern("abc", :codepoint)
      assert {:ok, ~r/^a.*c$/su} == Regex.compile_pattern("a*c", :codepoint)
      assert {:ok, ~r/^a.cc$/su} == Regex.compile_pattern("a?cc", :codepoint)

      assert {:ok, ~r/^a[bc]$/su} == Regex.compile_pattern("a[bc]", :codepoint)
      assert {:ok, ~r/^a[^bc]$/su} == Regex.compile_pattern("a[!bc]", :codepoint)
      assert {:ok, ~r/^foo-ba[a-zA-Z]$/su} == Regex.compile_pattern("foo-ba[a-zA-Z]", :codepoint)
      assert {:ok, ~r/^a\[bc$/su} == Regex.compile_pattern("a[bc", :codepoint)
      assert {:ok, ~r/^a[^b][^c]$/su} == Regex.compile_pattern("a[!b][!c]", :codepoint)
      assert {:ok, ~r/^a[\]b][^c]$/su} == Regex.compile_pattern("a[]b][!c]", :codepoint)
      assert {:ok, ~r/^[\[abc]$/su} == Regex.compile_pattern("[[abc]", :codepoint)
      assert {:ok, ~r/^b[bbca\[!abc]f$/su} == Regex.compile_pattern("b[bbca[!abc]f", :codepoint)
    end

    test ":byte" do
      assert {:ok, ~r/^abc$/s} == Regex.compile_pattern("abc", :byte)
    end
  end

  describe "match - unit tests" do
    test "literal match" do
      assert true == Regex.match?("foobar", "foobar", mode: :codepoint)
    end

    test "single character wildcard" do
      assert true == Regex.match?("foobar", "fo?bar", mode: :codepoint)
    end

    test "multiple character wildcard" do
      assert true == Regex.match?("foobar", "f*r", mode: :codepoint)
    end

    test "class of literals" do
      assert true == Regex.match?("foobar", "fooba[rR]", mode: :codepoint)
    end

    test "class with range" do
      assert true == Regex.match?("foobar", "fooba[a-zA-Z]", mode: :codepoint)
    end

    # http://man7.org/linux/man-pages/man7/glob.7.html
    test "class containing closing bracket" do
      # A closing square bracket can be the first character in a class
      assert true == Regex.match?("abc]def", "abc[]0]def", mode: :codepoint)
    end

    test "works with non-utf8 binaries" do
      assert true == Regex.match?(<<0, 1, 2>>, <<0, 1, ??>>, mode: :codepoint)
    end

    test "question mark matches exactly one codepoint in :codepoint mode" do
      assert true == Regex.match?("ł", "?", mode: :codepoint)
    end

    test "question mark matches exactly one byte in :byte mode" do
      assert true == Regex.match?("ł", "??", mode: :byte)
    end

    test "escaping is respected in the pattern" do
      assert true == Regex.match?("\\", "\\\\", mode: :codepoint)
      assert false == Regex.match?("\\", "\\", mode: :codepoint)
    end
  end

  describe "match - property tests" do
    property "should act the same as bash implementation for bytes" do
      forall {subject, pattern} <- Generators.byte_subject_and_pattern() do
        assert Bash.match?(subject, pattern) == Regex.match?(subject, pattern, mode: :byte)
      end
    end

    property "should act the same as bash implementation for codepoint" do
      forall {subject, pattern} <- Generators.codepoint_subject_and_pattern() do
        assert Bash.match?(subject, pattern) == Regex.match?(subject, pattern, mode: :codepoint)
      end
    end
  end
end
