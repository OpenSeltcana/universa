defmodule Universa.Component do
  use Ecto.Schema

  alias Universa.Repo
  alias Universa.Entity
  alias Universa.Component
  alias Universa.Event

  schema "components" do
    belongs_to(:entity, Entity)
    field(:key, :string, primary_key: true)
    field(:value, :map)
  end

  def create(uuid, key, value) when is_binary(uuid), do: create(Entity.uuid(uuid), key, value)

  @spec create(String.t() | Ecto.Schema.t(), String.t(), map) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create(entity, key, value) when is_map(entity) do
    safe_value = convert_value(value)

    result =
      %Component{entity_id: entity.id, key: key, value: safe_value}
      |> Repo.insert()

    {:ok, %Task{}} =
      %Event{
        type: :component,
        data: %{action: :create, key: key, value: safe_value},
        target: entity.uuid
      }
      |> Event.emit()

    result
  end

  def update(component, value) do
    component_full = Repo.preload(component, [:entity])
    safe_value = convert_value(value)

    result =
      component_full
      |> Ecto.Changeset.cast(%{value: safe_value}, [:value])
      |> Repo.update()

    {:ok, %Task{}} =
      %Event{
        type: :component,
        data: %{action: :update, key: component.key, old: component.value, new: safe_value},
        target: component_full.entity.uuid
      }
      |> Event.emit()

    result
  end

  def destroy(component) do
    component_full = Repo.preload(component, [:entity])

    result =
      component_full
      |> Repo.delete()

    {:ok, %Task{}} =
      %Event{
        type: :component,
        data: %{action: :destroy, key: component.key, value: component.value},
        target: component_full.entity.uuid
      }
      |> Event.emit()

    result
  end

  defp convert_value(value) do
    value
    |> Enum.map(fn {key, value} ->
      {
        case is_atom(key) do
          true -> Atom.to_string(key)
          false -> key
        end,
        value
      }
    end)
    |> Map.new()
  end
end
