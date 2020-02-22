defmodule Wild.ValidatorTest do
  use ExUnit.Case, async: true
  use PropCheck

  alias Wild.{Bash, Generators, Validator}

  describe "valid?" do
    test "returns false for invalid class" do
      assert false == Validator.valid?("[!]", :codepoint)
      assert false == Validator.valid?("foo[!]", :codepoint)
    end

    test "returns false for invalid escape sequence" do
      assert false == Validator.valid?("\\", :codepoint)
      assert false == Validator.valid?("\\a", :codepoint)
      assert false == Validator.valid?("\\\\\\", :codepoint)
    end

    test "returns true for valid escape sequence" do
      assert true == Validator.valid?("\\?", :codepoint)
      assert true == Validator.valid?("\\*", :codepoint)
      assert true == Validator.valid?("\\\\", :codepoint)
    end
  end

  property "any invalid patterns should evaluate to false in Bash" do
    forall pattern <- Generators.random_pattern() do
      implies Validator.match?(pattern) == false do
        assert Bash.match?("hello", pattern) == false
      end
    end
  end

  property "any pattern that evalauted to true in Bash must be a valid pattern (:codepoint)" do
    forall {subject, pattern} <- Generators.codepoint_subject_and_pattern() do
      implies Bash.match?(subject, pattern) do
        assert Validator.valid?(pattern, :codepoint) == true
      end
    end
  end

  property "any pattern that evalauted to true in Bash must be a valid pattern (:byte)" do
    forall {subject, pattern} <- Generators.codepoint_subject_and_pattern() do
      implies Bash.match?(subject, pattern) do
        assert Validator.valid?(pattern, :byte) == true
      end
    end
  end
end
