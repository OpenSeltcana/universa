defmodule Universa.System do
  @callback events() :: [String.t]
  @callback parse(atom, any) :: :ok | :error

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
      def events, do: @events
    end
  end

  defmacro parse(type, data, [do: block]), do: parse_header(type, data, block)

  defp parse_header(type, data, block) do
    quote do
      @events @events ++ [unquote(type)]

      def parse(unquote(type), unquote(data)), do: unquote(block)
    end
  end
end