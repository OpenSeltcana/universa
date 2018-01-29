defmodule Universa.Component.Name do
  @moduledoc """
  This component gives an entity a description, people like descriptions.
  """
  use Universa.Core.Component
  @component_key "spec"

  defstruct value: nil

  def new(%{"name" => name}), do: %__MODULE__{value: name}

  defimpl String.Chars do
    def to_string(%{value: name}), do: name
  end
end
