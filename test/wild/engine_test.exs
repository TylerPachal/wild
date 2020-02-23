defmodule Wild.EngineTest do
  use ExUnit.Case, async: true
  use PropCheck

  alias Wild.{Bash, Engine, Generators}

  describe "compile_pattern" do
    test ":codepoint" do
      assert {:ok, ~r/^abc$/su} == Engine.compile_pattern("abc", :codepoint)
      assert {:ok, ~r/^a.*c$/su} == Engine.compile_pattern("a*c", :codepoint)
      assert {:ok, ~r/^a.cc$/su} == Engine.compile_pattern("a?cc", :codepoint)

      assert {:ok, ~r/^a[bc]$/su} == Engine.compile_pattern("a[bc]", :codepoint)
      assert {:ok, ~r/^a[^bc]$/su} == Engine.compile_pattern("a[!bc]", :codepoint)
      assert {:ok, ~r/^foo-ba[a-zA-Z]$/su} == Engine.compile_pattern("foo-ba[a-zA-Z]", :codepoint)
      assert {:ok, ~r/^a\[bc$/su} == Engine.compile_pattern("a[bc", :codepoint)
      assert {:ok, ~r/^a[^b][^c]$/su} == Engine.compile_pattern("a[!b][!c]", :codepoint)
      assert {:ok, ~r/^a[\]b][^c]$/su} == Engine.compile_pattern("a[]b][!c]", :codepoint)
      assert {:ok, ~r/^[\[abc]$/su} == Engine.compile_pattern("[[abc]", :codepoint)
      assert {:ok, ~r/^b[bbca\[!abc]f$/su} == Engine.compile_pattern("b[bbca[!abc]f", :codepoint)
    end

    test ":byte" do
      assert {:ok, ~r/^abc$/s} == Engine.compile_pattern("abc", :byte)
      assert {:ok, ~r/^[aa\na\[!abc]a.$/s} == Engine.compile_pattern("[aa\na[!abc]a?", :byte)
    end
  end

  describe "match - unit tests" do
    test "literal match" do
      assert true == Engine.match?("foobar", "foobar", mode: :codepoint)
    end

    test "single character wildcard" do
      assert true == Engine.match?("foobar", "fo?bar", mode: :codepoint)
    end

    test "multiple character wildcard" do
      assert true == Engine.match?("foobar", "f*r", mode: :codepoint)
    end

    test "class of literals" do
      assert true == Engine.match?("foobar", "fooba[rR]", mode: :codepoint)
    end

    test "class with range" do
      assert true == Engine.match?("foobar", "fooba[a-zA-Z]", mode: :codepoint)
    end

    # http://man7.org/linux/man-pages/man7/glob.7.html
    test "class containing closing bracket" do
      # A closing square bracket can be the first character in a class
      assert true == Engine.match?("abc]def", "abc[]0]def", mode: :codepoint)
    end

    test "works with non-utf8 binaries" do
      assert true == Engine.match?(<<0, 1, 2>>, <<0, 1, ??>>, mode: :codepoint)
    end

    test "question mark matches exactly one codepoint in :codepoint mode" do
      assert true == Engine.match?("ł", "?", mode: :codepoint)
    end

    test "question mark matches exactly one byte in :byte mode" do
      assert true == Engine.match?("ł", "??", mode: :byte)
    end

    test "escaping is respected in the pattern" do
      assert true == Engine.match?("\\", "\\\\", mode: :codepoint)
      assert false == Engine.match?("\\", "\\", mode: :codepoint)
    end

    test "regressions" do
      assert false == Engine.match?("[aa\na ad", "[aa\na[!abc]a?", mode: :byte)
      assert true == Engine.match?("bhstw", "*[!-a--]", mode: :codepoint)
    end
  end

  describe "match - property tests" do
    property "should act the same as bash implementation for mode: :byte" do
      forall {subject, pattern} <- Generators.byte_subject_and_pattern() do
        assert Bash.match?(subject, pattern) == Engine.match?(subject, pattern, mode: :byte)
      end
    end

    property "should act the same as bash implementation for mode: :codepoint" do
      forall {subject, pattern} <- Generators.codepoint_subject_and_pattern() do
        assert Bash.match?(subject, pattern) == Engine.match?(subject, pattern, mode: :codepoint)
      end
    end
  end
end
