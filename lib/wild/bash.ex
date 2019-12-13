defmodule Wild.Bash do

  def match?(string, pattern, opts \\ []) do
    flags = []
    command = [string, pattern] ++ flags

    {output, return} =
      System.cwd()
      |> Path.join("./scripts/wildcard_test.sh")
      |> System.cmd(command)

    if Keyword.get(opts, :verbose) do
      IO.puts("Ouput: #{output}")
      IO.puts("Return: #{return}")
    end

    return == 0
  end
end
