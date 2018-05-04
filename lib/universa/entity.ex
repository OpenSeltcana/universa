defmodule Universa.Entity do
  use Ecto.Schema

  import Ecto.Query

  alias Universa.Repo
  alias Universa.Entity
  alias Universa.Component
  alias Universa.Event

  schema "entities" do
    field :uuid, :string
    has_many :components, Component
    timestamps()
  end

  def create do
    uuid = Ecto.UUID.generate()
    result = %Entity{uuid: uuid} |> Repo.insert

    %Event{type: :entity, data: %{action: :create}, target: uuid}
    |> Event.emit

    result
  end

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

  def destroy(entity) do
    result = entity
    |> Repo.delete

    %Event{type: :entity, data: %{action: :destroy}, target: entity.uuid}
    |> Event.emit

    result
  end
end