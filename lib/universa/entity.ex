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

  def uuid(%Entity{} = ent), do: ent

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

  def load_from_file(entity, path) do
    full_path = Path.join(:code.priv_dir(:universa), "entity/#{path}.yml")

    with {:ok, yaml} <- YamlElixir.read_from_file(full_path) do
      yaml
      |> Enum.each(fn {key, value} ->
        case key do
          "inherit" ->
            case value do
              files when is_list(files) ->
                Enum.each(files, fn file ->
                  relative_path = Path.expand(file, "/#{path}")
                  load_from_file(entity, relative_path)
                end)
              file when is_binary(file) ->
                relative_path = Path.expand(file, "/#{path}")
                load_from_file(entity, relative_path)
            end
          _ ->
            case is_binary(value) do
              true ->
                Component.create(entity, key, %{value: value})
              false ->
                Component.create(entity, key, value)
            end
        end
      end)
    end
  end

  def dump(entity) do
    Repo.preload(uuid(entity), [:components])
  end

  def destroy(entity) do
    result = entity
    |> Repo.delete

    %Event{type: :entity, data: %{action: :destroy}, target: entity.uuid}
    |> Event.emit

    result
  end
end