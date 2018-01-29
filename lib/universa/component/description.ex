defmodule Universa.Component.Description do
  @moduledoc """
  This component gives an entity a description, people like descriptions.
  """
  use Universa.Core.Component
  @component_key "appearance"

  defstruct value: nil

  def new(%{"description" => description}), do: %__MODULE__{value: description}

  defimpl String.Chars do
    def to_string(%{value: description}), do: description
  end
end
