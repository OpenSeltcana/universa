defmodule Universa.Parser do
  @callback parse(binary, map) :: {:stop | :keep_going, [map]}

  alias Universa.Entity

  defmacro __using__(_options) do
    quote location: :keep do
      import Universa.Parser
      @behaviour Universa.Parser
      @before_compile Universa.Parser

      def order, do: 50

      defoverridable [order: 0]
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def parse(_, _), do: {:keep_going, []}
    end
  end

  def each(message, %Entity{} = entity, []), do: {:keep_going, []}

  def each(message, %Entity{} = entity, [[_order, module] | others]) do
    case apply(String.to_existing_atom(module), :parse, [message, entity]) do
      {:keep_going, events} -> 
        {msg, events_others} = each(message, entity, others)
        {msg, events ++ events_others}
      {:stop, events} -> {:stop, events}
    end
  end
end