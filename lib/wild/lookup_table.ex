defmodule Wild.LookupTable do
  @moduledoc false

  def create(string_length, pattern_length) do
    rows = string_length
    columns = pattern_length

    for x <- 0..rows,
        y <- 0..columns,
        into: %{}
    do
      {{x, y}, false}
    end
  end

  def get(table, x, y) when is_integer(x) and is_integer(y) do
    Map.fetch!(table, {x, y})
  end

  def set(table, x, y, value) when is_integer(x) and is_integer(y) and is_boolean(value) do
    Map.put(table, {x, y}, value)
  end

  def print(table) do
    val_func = fn
      true -> 1
      false -> 0
    end

    IO.puts("--- Table ---")
    table
    |> Enum.sort()
    |> Enum.group_by(fn {{row, _col}, _val} -> row end, fn {{_row, _col}, val} -> val_func.(val) end)
    |> Enum.map(fn {_, row} -> row end)
    |> Enum.each(&IO.inspect/1)

    table
  end
end
