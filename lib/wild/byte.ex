defmodule Wild.Byte do
  use Wild.Matcher

  @question_mark ??
  @asterisk ?*
  @backslash ?\\
  @left_square_bracket ?[
  @right_square_bracket ?]
  @dash ?-

  def split(string), do: :binary.bin_to_list(string)
end
