defmodule Wild.MixProject do
  use Mix.Project

  def project do
    [
      app: :wild,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
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
      description: "A wildcard matching library that aims to mimic Bash functionality",
      files: ["priv", "lib", "config", "mix.exs", "README*"],
      maintainers: ["Tyler Pachal"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/TylerPachal/wild"}
    ]
  end
end
