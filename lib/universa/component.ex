defmodule Universa.Component do
  use Ecto.Schema

  alias Universa.Repo
  alias Universa.Entity
  alias Universa.Component

  schema "components" do
    belongs_to :entity, Entity
    field :key, :string, primary_key: true
    field :value, :map
  end

  def create(uuid, key, value) when is_binary(uuid), do: create(Entity.uuid(uuid), key, value)

  def create(entity, key, value) when is_map(entity) do
  	%Component{entity_id: entity.id, key: key, value: value}
  	|> Repo.insert
  end

  def update(component, value) do
  	component
  	|> Ecto.Changeset.cast(%{value: value}, [:value])
  	|> Repo.update
  end

  def delete(component) do
  	component
  	|> Repo.delete
  end
end