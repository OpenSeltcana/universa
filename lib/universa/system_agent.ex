defmodule Universa.SystemAgent do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> all_systems() end, name: __MODULE__)
  end

  def systems(event) do
    Agent.get(__MODULE__, &Map.fetch(&1, event))
  end

  def update do
    Agent.update(__MODULE__, all_systems())
  end

  defp all_systems do
    %{terminal: [Universa.System.Terminal, Universa.System.Debug], test: [Universa.System.Debug]}
  end
end