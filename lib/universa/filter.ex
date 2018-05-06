defmodule Universa.Filter do
  @callback get(list, map) :: {list, map}
  @callback put(list, map) :: {list, map}

  defmacro __using__(_options) do
    quote location: :keep do
      @behaviour Universa.Filter
    end
  end
end