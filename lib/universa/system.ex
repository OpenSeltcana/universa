defmodule Universa.System do
  @callback events() :: [String.t]
  @callback parse(atom, any) :: boolean

  defmacro __using__(_options) do
    quote location: :keep do
      import unquote(__MODULE__)
      @behaviour unquote(__MODULE__)
    end
  end
end