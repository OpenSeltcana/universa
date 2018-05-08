defmodule Universa.Parser do
  @callback parse(binary, map) :: boolean

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
      def parse(_, _), do: false
    end
  end
end