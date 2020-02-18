defmodule Wild.RegexTest do
  use ExUnit.Case, async: true
  use PropCheck

  alias Wild.{Bash, Regex, Generators}

  describe "compile_pattern" do
    test "compile_pattern" do
      assert {:ok, ~r/^abc$/s} == Regex.compile_pattern("abc")
      assert {:ok, ~r/^a.*c$/s} == Regex.compile_pattern("a*c")
      assert {:ok, ~r/^a.cc$/s} == Regex.compile_pattern("a?cc")

      assert {:ok, ~r/^a[bc]$/s} == Regex.compile_pattern("a[bc]")
      assert {:ok, ~r/^a[^bc]$/s} == Regex.compile_pattern("a[!bc]")
      assert {:ok, ~r/^foo-ba[a-zA-Z]$/s} == Regex.compile_pattern("foo-ba[a-zA-Z]")
      assert {:ok, ~r/^a\[bc$/s} == Regex.compile_pattern("a[bc")
      assert {:ok, ~r/^a[^b][^c]$/s} == Regex.compile_pattern("a[!b][!c]")
      assert {:ok, ~r/^a[\]b][^c]$/s} == Regex.compile_pattern("a[]b][!c]")
      assert {:ok, ~r/^[\[abc]$/s} == Regex.compile_pattern("[[abc]")
      assert {:ok, ~r/^b[bbca\[\!abc]f$/s} == Regex.compile_pattern("b[bbca[!abc]f")
    end
  end

  describe "match - unit tests" do
    test "literal match" do
      assert true == Regex.match?("foobar", "foobar")
    end

    test "single character wildcard" do
      assert true == Regex.match?("foobar", "fo?bar")
    end

    test "multiple character wildcard" do
      assert true == Regex.match?("foobar", "f*r")
    end

    test "class of literals" do
      assert true == Regex.match?("foobar", "fooba[rR]")
    end

    test "class with range" do
      assert true == Regex.match?("foobar", "fooba[a-zA-Z]")
    end

    # http://man7.org/linux/man-pages/man7/glob.7.html
    test "class containing closing bracket" do
      # A closing square bracket can be the first character in a class
      assert true == Regex.match?("abc]def", "abc[]0]def")
    end

    test "works with non-utf8 binaries" do
      assert true == Regex.match?(<<0, 1, 2>>, <<0, 1, ??>>)
    end

    test "question mark matches exactly one byte" do
      assert false == Regex.match?("", "?")
      assert false == Regex.match?("a", "??")
      assert true == Regex.match?("aa", "??")
      assert true == Regex.match?("aa", "a?")
      assert true == Regex.match?("ł", "??")
    end
  end

  describe "match - property tests" do
    property "star should always match anything" do
      forall subject <- Generators.subject() do
        assert true == Regex.match?(subject, "*")
      end
    end

    property "question mark should always match strings that one characters long" do
      forall subject <- Generators.string(1) do
        assert true == Regex.match?(subject, "?")
      end
    end

    property "should act the same as bash implementation" do
      forall {subject, pattern} <- Generators.byte_subject_and_pattern() do
        assert Bash.match?(subject, pattern) == Regex.match?(subject, pattern)
      end
    end
  end

end
