defmodule Universa.System do
  defmacro __using__(_options) do
    quote location: :keep do
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote location: :keep do
      def handle(_,_), do: false
    end
  end
end
