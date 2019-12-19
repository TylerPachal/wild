defmodule Wild.Byte do
  @moduledoc false

  use Wild.Matcher

  @question_mark ??
  @asterisk ?*
  @backslash ?\\
  @left_square_bracket ?[
  @right_square_bracket ?]
  @dash ?-
  @exclamation_mark ?!

  def split(string), do: :binary.bin_to_list(string)

  def range_to_list(range_start, range_end) do
    Enum.to_list(range_start..range_end)
  end
end
