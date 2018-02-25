defmodule Universa.MixProject do
  use Mix.Project

  def project do
    [
      app: :universa,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Universa, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      { :uuid, "~> 1.1" },
      { :credo, "~> 0.9.0-rc1", only: [:dev, :test], runtime: false }
    ]
  end
end
