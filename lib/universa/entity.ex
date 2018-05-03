defmodule Universa.Entity do
  use Ecto.Schema

  import Ecto.Query

  alias Universa.Repo
  alias Universa.Entity
  alias Universa.Component

  schema "entities" do
    field :uuid, :string
    has_many :components, Component
    timestamps()
  end

  def create, do: %Entity{uuid: Ecto.UUID.generate()} |> Repo.insert

  def uuid(uuid) do
  	Entity
  	|> where([e], e.uuid == ^uuid)
  	|> Repo.one
  end

  def component(entity, key) when is_map(entity) do
  	Component
  	|> where([c], c.entity_id == ^entity.id and c.key == ^key)
  	|> Repo.one
  end

  def component(uuid, key) when is_binary(uuid) do
  	Entity
  	|> join(:left, [e], c in Component, c.entity_id == e.id and e.uuid == ^uuid)
  	|> where([e, c], c.key == ^key)
  	|> select([e, c], c)
  	|> Repo.one
  end

  def delete(entity) do
  	entity
  	|> Repo.delete
  end
end