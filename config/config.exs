use Mix.Config

# If we are running CI do more tests
if System.get_env("GITHUB_ACTION") do
  import_config "ci.exs"
end
