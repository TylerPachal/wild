defmodule WildTest do
  use ExUnit.Case, async: true
  use PropCheck

  describe "valid_pattern?" do
    # TODO: Add property tests

    test "returns false for invalid class" do
      assert false == Wild.valid_pattern?("[!]")
      assert false == Wild.valid_pattern?("foo[!]")
    end

    test "returns false for invalid escape sequence" do
      assert false == Wild.valid_pattern?("\\")
      assert false == Wild.valid_pattern?("\\a")
      assert false == Wild.valid_pattern?("\\\\\\")
    end

    test "returns true for valid escape sequence" do
      assert true == Wild.valid_pattern?("\\?")
      assert true == Wild.valid_pattern?("\\*")
      assert true == Wild.valid_pattern?("\\\\")
    end
  end
end
