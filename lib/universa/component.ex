defmodule Universa.Component do
  @def_value nil

  defmacro __using__(_options) do
    quote location: :keep do
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote location: :keep do
      use GenServer

      defstruct entity_id: nil, value: @def_value

      def new(), do: Universa.ComponentSupervisor.new(__MODULE__)

      def new(uuid) do
        Universa.ComponentSupervisor.new(__MODULE__, uuid)
      end

      def new(uuid, value) do
	Universa.ComponentSupervisor.new(__MODULE__, uuid, value)
      end

      def start_link([uuid, value]) do
	GenServer.start_link(__MODULE__,
               struct(__MODULE__, %{entity_id: uuid, value: value}))
      end

      def start_link([uuid]) do
        GenServer.start_link(__MODULE__,
                             struct(__MODULE__, %{entity_id: uuid}))
      end

      def start_link([]), do: start_link([UUID.uuid1()])

      def init(state) do
        uuid = Map.get(state, :entity_id)
        {:ok, _} = Universa.Channel.Entity.subscribe(uuid, __MODULE__)
        {:ok, state}
      end

      # Server functions

      def handle_call(:get_entity_id, _from, state) do
        reply =
          state
          |> Map.get(:entity_id)
        {:reply, reply, state}
      end

      def handle_call(:get_type, _from, state) do
        {:reply, __MODULE__, state}
      end

      def handle_call(:get_value, _from, state) do
        reply =
          state
          |> Map.get(:value)
        {:reply, reply, state}
      end

      def handle_cast({:set_value, value}, state) do
        newstate =
          state
          |> Map.update!(:value, fn _old ->
            value
          end)
        {:noreply, newstate}
      end
    end
  end

  defmacro default_value(value) do
    quote do
      @def_value unquote(value)
    end
  end

  # Client functions

  def get_entity_id(pid) do
    GenServer.call(pid, :get_entity_id)
  end

  def get_type(pid) do
    GenServer.call(pid, :get_type)
  end

  def get_value(pid) do
    GenServer.call(pid, :get_value)
  end

  def set_value(pid, value) do
    GenServer.cast(pid, {:set_value, value})
  end

  def remove(pid) do
    Universa.ComponentSupervisor.rem(pid)
  end
end
