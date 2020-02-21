defmodule Wild.MixProject do
  use Mix.Project

  @source_url "https://github.com/TylerPachal/wild"

  def project do
    [
      app: :wild,
      version: "1.0.0-rc.3",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
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

  defp elixirc_paths(:test), do: ["lib", "test/support", "test/mix"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:propcheck, "~> 1.2", only: :test},
      {:exprof, "~> 0.2.3", only: :test},
      {:benchee, "~> 1.0", only: :test},
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
