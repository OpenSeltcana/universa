defmodule Universa.System do
  @callback events() :: [String.t]
  @callback event(number, atom, any) :: :ok | :error

  defmacro __using__(_options) do
    quote location: :keep do
      import Universa.System
      @behaviour Universa.System
      @before_compile Universa.System
      @events []
    end
  end

  defmacro __before_compile__(_options) do
    quote do
      def event(_, _, _), do: :error

      def events, do: @events
    end
  end

  defmacro event(order, type, data, [do: block]), do: parse_header(order, type, data, block)

  defp parse_header(order, type, data, block) do
    quote do
      @events @events ++ [{unquote(order), unquote(type)}]

      def event(unquote(order), unquote(type), unquote(data)), do: unquote(block)
    end
  end
end