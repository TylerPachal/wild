defmodule Wild.Bash do

  def match?(string, pattern, opts \\ []) do
    flags =
      if Keyword.get(opts, :verbose) do
        ["-v"]
      else
        []
      end
    command = [string, pattern] ++ flags

    {output, return} =
      System.cwd()
      |> Path.join("./scripts/wildcard_test.sh")
      |> System.cmd(command)

    if Keyword.get(opts, :verbose) do
      print_output(output)
      IO.puts("[Elixir] Return: #{return}")
    end

    return == 0
  end

  defp print_output(output) do
    IO.puts(output)
  catch _, _ ->
    IO.puts("[Elixir] Cannot print output - non printable binary")
  end
end
