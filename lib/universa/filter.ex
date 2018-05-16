defmodule Universa.Filter do
  @callback get(list, map) :: {list, map}
  @callback put(list, map) :: {list, map}

  alias Universa.Filter

  defmacro __using__(_options) do
    quote location: :keep do
      @behaviour Filter
    end
  end
end