defmodule Wild.MixProject do
  use Mix.Project

  def project do
    [
      app: :wild,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:propcheck, "~> 1.2", only: [:dev, :test]}
    ]
  end
end
