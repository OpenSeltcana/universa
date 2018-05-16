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
      extra_applications: [:logger, :sqlite_ecto2, :ecto, :yaml_elixir, :ssl]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
#      {:distillery, "~> 1.5", runtime: false},
      {:argon2_elixir, "~> 1.2"},
      {:yaml_elixir, "~> 2.0"},
      {:poison, "~> 3.1"}, # For converting maps to JSON
      {:ecto, "~> 2.2"}, # For interface with databases and UUID generation
      {:sqlite_ecto2, "~> 2.2"} # Adapter for ecto to connect to sqlite3 databases
    ]
  end
end
