defmodule Universa.Shell do
  @callback on_load(map) :: {[map], map}
  @callback input(list, map) :: {[map], map}
  @callback output(map, map) :: {list, map}
  @callback on_unload(map) :: {[map], map}

  alias Universa.Shell

  defmacro __using__(_options) do
    quote location: :keep do
      @behaviour Shell
    end
  end
end