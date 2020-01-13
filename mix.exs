defmodule Wild.MixProject do
  use Mix.Project

  @source_url "https://github.com/TylerPachal/wild"

  def project do
    [
      app: :wild,
      version: "1.0.0-rc.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      package: package(),
      description: description(),

      # Docs
      name: "Wild",
      docs: docs(),
      source_url: @source_url,
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:propcheck, "~> 1.2", only: [:dev, :test]},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      description: description(),
      files: ["priv", "lib", "config", "mix.exs", "README*"],
      maintainers: ["Tyler Pachal"],
      licenses: ["MIT"],
      links: %{github: @source_url}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      source_url: @source_url,
      extra_section: "Overview"
    ]
  end

  defp description do
    "Wild is a wildcard matching library that mimics unix-style pattern matching functionality in Elixir"
  end
end
