defmodule Universa.System do
  @callback event(any(), any(), any()) :: any()
  @callback events() :: any()

  @moduledoc "Helps creating Systems and maintains a list of all systems."

  use GenServer

  defmacro __using__(_options) do
    quote location: :keep do
      import Universa.System
      @behaviour Universa.System
      @before_compile Universa.System
      @events []
    end
  end

  defmacro __before_compile__(_options) do
    quote location: :keep do
      def event(_, _, _), do: :error

      def events, do: @events
    end
  end

  defmacro event(order, type, data, do: block) do
    quote location: :keep do
      @events @events ++ [{unquote(order), unquote(type)}]

      def event(unquote(order), unquote(type), unquote(data)), do: unquote(block)
    end
  end

  @doc "Get a list of all systems that handle event of type `type` from the GenServer."
  def list(type), do: GenServer.call(__MODULE__, {:list, type})

  @doc "Request the GenServer to generate the list of systems from scratch."
  def reload(), do: GenServer.cast(__MODULE__, :reload)

  @doc "Starts a GenServer that keeps a list of all systems, used by `list/1` and `reload/0`."
  def start_link([]), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  @impl true
  def init(_state) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:list, type}, _from, state) do
    {:reply, Map.fetch(state, type), state}
  end

  @impl true
  def handle_cast(:reload, _state) do
    {:noreply, all_systems()}
  end

  # Returns an ordered list of all systems, keyed by event type
  defp all_systems() do
    []
    # Get a list of all modules in the universa project that implement the Universa.System behaviour
    # with {:ok, modules} <- :application.get_key(:universa, :modules) do
    #   modules
    #   |> Enum.filter(fn module ->
    #     module.module_info[:attributes]
    #     |> Keyword.get(:behaviour, [])
    #     |> Enum.member?(System)
    #   end)
    # end
    # Get a list of all applications
    Application.loaded_applications()
    # Get a list of all modules per application
    |> Enum.flat_map(fn {module, _name, _version} ->
      Application.spec(module, :modules)
    end)
    # Filter out all modules that dont implement this module
    |> Enum.filter(fn module ->
        module.module_info[:attributes]
        |> Keyword.get(:behaviour, [])
        |> Enum.member?(__MODULE__)
      end)
    # Add an entry for every event this system handles in the format of {event, system}
    |> Enum.flat_map(fn system ->
      apply(system, :events, [])
      |> Enum.map(fn {priority, event} -> {event, priority, system} end)
    end)
    # Sort systems based on priority
    |> Enum.sort(fn {_event1, priority1, _system1}, {_event2, priority2, _system2} ->
      priority1 >= priority2
    end)
    # Remove any duplicates (because they are checking different events)
    |> Enum.uniq()
    # Group systems under the same event
    |> Enum.group_by(&Kernel.elem(&1, 0), &{elem(&1, 1), elem(&1, 2)})
  end
end
