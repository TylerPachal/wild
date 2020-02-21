defmodule Mix.Tasks.Race do
  @moduledoc """
  Races one implentation against another.  Only for testing purposes.

  Example usage:

      MIX_ENV=test mix race
  """
  @shortdoc "Races one implentation against another"

  use Mix.Task
  alias Wild.Generators

  def run(_args) do
    list = input_data()

    Benchee.run(%{
      "wild" => fn ->
        Enum.each(list, fn {s, p} -> Wild.match?(s, p) end)
      end,
      "bash" => fn ->
        Enum.each(list, fn {s, p} -> Wild.match?(s, p, mode: :bash) end)
      end
    })
  end

  # Generate a bunch of random samples with evenly distributed input sizes
  defp input_data(options \\ []) do
    total = options[:total] || 100
    max_size = options[:max_size] || 100
    min_size = options[:min_size] || 0
    gen = Generators.codepoint_subject_and_pattern()

    step = (max_size - min_size) / total
    Enum.map(1..total, fn num ->
      size = Kernel.trunc(num * step)
      {:ok, {subject, pattern}} = PropCheck.produce(gen, size)
      {subject, pattern}
    end)
  end
end
