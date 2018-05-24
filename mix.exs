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
      # {:distillery, "~> 1.5", runtime: false},
      {:dialyzex, "~> 1.1.0", only: :dev},
      {:argon2_elixir, "~> 1.2"},
      {:yaml_elixir, "~> 2.0"},
      # For converting maps to JSON
      {:poison, "~> 3.1"},
      # For interface with databases and UUID generation
      {:ecto, "~> 2.2"},
      # Adapter for ecto to connect to sqlite3 databases
      {:sqlite_ecto2, "~> 2.2"}
    ]
  end
end
