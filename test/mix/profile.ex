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
    profile do: Wild.match?("pattern", "pat[^abc]e?n", mode: :codepoint)
  end

end
