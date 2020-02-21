defmodule Mix.Tasks.Profile do
  @moduledoc """
  Profiles one function using ExProf.  Only for testing purposes.

  Example usage:

      MIX_ENV=test mix profile
  """
  @shortdoc "Profiles one function using ExProf"

  use Mix.Task
  import ExProf.Macro

  def run(_args) do
    profile do: do_work()
  end

  defp do_work() do
    Wild.match?("subject", "pattern")
  end

end
