defmodule Mix.Tasks.Profile do
  @moduledoc """
  Profiles one function using ExProf.

  Example usage:

      mix profile
  """
  @shortdoc "Profiles one function using ExProf"

  use Mix.Task
  import ExProf.Macro

  def run(_args) do
    profile do: do_work()
  end

  defp do_work() do
    Wild.Regex.match?("subject", "pattern")
  end

end
