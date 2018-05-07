defmodule Universa.SystemAgent do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> all_systems() end, name: __MODULE__)
  end

  # Get all systems with a function for this event type
  def systems(event) do
    Agent.get(__MODULE__, &Map.fetch(&1, event))
  end

  def reload do
    Agent.update(__MODULE__, fn _ -> all_systems() end)
  end

  # Returns an ordered list of all systems, keyed by event type
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
      apply(system, :events, [])
      |> Enum.map(fn {priority, event} -> {event, priority, system} end)
    end)
    # Sort systems based on priority
    |> Enum.sort(fn {_event1, priority1, _system1}, {_event2, priority2, _system2} -> priority1 >= priority2 end)
    # Remove any duplicates (because they are checking different events)
    |> Enum.uniq
    # Group systems under the same event
    |> Enum.group_by(&Kernel.elem(&1, 0), &({elem(&1, 1), elem(&1, 2)}))
  end
end