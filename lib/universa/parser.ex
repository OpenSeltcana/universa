defmodule Universa.Parser do
  @callback parse(binary, map) :: {:stop | :keep_going, [map]}

  alias Universa.Entity
  alias Universa.Parser

  require Logger

  defmacro __using__(_options) do
    quote location: :keep do
      import Parser
      @behaviour Parser
      @before_compile Parser

      def order, do: 50

      defoverridable order: 0
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def parse(_, _), do: {:keep_going, []}
    end
  end

  @spec each(map, map, list({number, atom})) :: {:keep_going | :stop, list(map)}
  def each(_message, _entity, []), do: {:keep_going, []}

  def each(message, %Entity{} = entity, [[_order, module] | others]) do
    try do
      case apply(module, :parse, [message, entity]) do
        {:keep_going, events} ->
          {msg, events_others} = each(message, entity, others)
          {msg, events ++ events_others}

        {:stop, events} ->
          {:stop, events}
      end
    rescue
      error ->
        Logger.error("Parser #{module}.parse/2 failed with:\n#{Exception.format(:error, error)}")
    end
  end
end