defmodule Universa.Helpers do
  def reload(module) when is_atom(module) do
    {:reloaded, _, _} = IEx.Helpers.r(module)

    if module.module_info[:attributes]
      |> Keyword.get(:behaviour, [])
      |> Enum.member?(Universa.System) do
      Universa.System.reload()
    end
  end
end