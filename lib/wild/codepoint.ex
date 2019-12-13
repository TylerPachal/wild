defmodule Wild.Codepoint do
  use Wild.Matcher

  @question_mark "?"
  @asterisk "*"
  @backslash "\\"
  @left_square_bracket "["
  @right_square_bracket "]"
  @dash "-"

  def split(string), do: String.codepoints(string)

  def range_to_list(range_start, range_end) do
    [a, b] = String.to_charlist(range_start <> range_end)
    Enum.map(a..b, fn x -> <<x :: utf8>> end)
  end
end
