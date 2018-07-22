defmodule Universa.Entity do
  alias Universa.Database
  alias Universa.Entity

  defstruct Map.to_list(Database.Entity.__struct__())

  def create do
    entity = %Database.Entity{uuid: UUID.uuid4()}

    Database.run(fn ->
      Database.write(entity)
    end)

    database_to_local(entity)
  end

  def take(uuid) do
    case Database.run(fn ->
      Database.read(Database.Entity, uuid: uuid)
    end) do
      nil -> nil
      entity -> database_to_local(entity)
    end
  end

  def store(%Entity{} = entity) do
    database_entity = local_to_database(entity)

    Database.run(fn ->
      Database.write(database_entity)
    end)
  end

  def delete(%Entity{} = entity) do
    database_entity = local_to_database(entity)

    Database.run(fn ->
      Database.delete(database_entity)
    end)
  end

  def list() do
    Database.run(fn ->
      Database.find(Database.Entity, [])
    end)
  end

  def from_file(file) do
    local_path = "priv/entities/#{file}.yml"
    default_path = Path.join(:code.priv_dir(:universa), "entities/#{file}.yml")

    cond do
      File.exists?(local_path) -> # Try local files first
        unsafe_from_file(local_path)
      File.exists?(default_path) -> # Then try Universa's files
        unsafe_from_file(default_path)
      true -> # Then give up
        nil
    end

  end

  defp unsafe_from_file(path) do
    {:ok, template} = YamlElixir.read_from_file(path)

    entity = create()
    Enum.each(template, fn {component, properties} ->
      module = String.to_existing_atom("Elixir.Universa.Component.#{String.capitalize(component)}")
      module.create(entity, Enum.map(properties, fn {key, value} -> {String.to_atom(key), value} end) |> Map.new)
    end)

    entity
  end

  # Conversion between %Universa.Database.Entity{} and %Universa.Entity{}
  defp database_to_local(%Database.Entity{} = ent) do
    struct(Entity, Map.to_list(ent))
  end

  defp local_to_database(%Entity{} = ent) do
    struct(Database.Entity, Map.to_list(ent))
  end
end
