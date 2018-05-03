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
    # Get a list of all modules in the universa project that implement the Universa.System behaviour
    with {:ok, modules} <- :application.get_key(:universa, :modules) do
      modules
      |> Enum.filter(fn module ->
        module.module_info[:attributes]
        |> Keyword.get(:behaviour, [])
        |> Enum.member?(Universa.System)
      end)
    end
    # Add an entry for every event this system handles in the format of {event, system}
    |> Enum.flat_map(fn system ->
      events = apply(system, :events, [])
      |> Enum.map(fn event -> {event, system} end)
    end)
    # Group systems under the same event
    |> Enum.group_by(&Kernel.elem(&1, 0), &Kernel.elem(&1, 1))
  end
end