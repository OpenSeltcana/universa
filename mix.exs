defmodule Universa.MixProject do
  use Mix.Project

  def project do
    [
      app: :universa,
      version: "0.1.0",
      description: "The MUD codebase of the future",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      dialyzer: [flags: ["-Wunmatched_returns", :error_handling, :race_conditions, :underspecs]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:logger, :mnesia],
      mod: {Universa, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.18.0", only: :dev, runtime: false, optional: true},
      {:dialyxir, "~> 1.0.0-rc.2", only: :dev, runtime: false, optional: true},
      {:elixir_uuid, "~> 1.2"},
      {:yaml_elixir, "~> 2.1"},
    ]
  end

  defp docs do
    [
      groups_for_modules: [
        Methods: [
          Universa.Shell,
          Universa.Filter,
          Universa.Component,
          Universa.Database.Table,
          Universa.System,
          Universa.Parser
        ],
        Database: [Universa.Database, Universa.Database.PeriodicSave],
        "Database Tables": ~r"Universa.Database.",
        Filters: ~r"Universa.Filter.",
        Systems: ~r"Universa.System.",
        Components: ~r"Universa.Component.",
        Shells: ~r"Universa.Shell.",
        Parsers: ~r"Universa.Parser."
      ]
    ]
  end
end
