defmodule Universa.Filter do
  @callback get(list, map) :: {map, list()}
  @callback put(list, map) :: {map, list()}

  alias Universa.Filter

  defmacro __using__(_options) do
    quote location: :keep do
      @behaviour Filter
    end
  end
end