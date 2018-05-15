defmodule Universa.Channel do
  use Ecto.Schema

  import Ecto.Query

  alias Universa.Repo
  alias Universa.Channel

  schema "channels" do
    field :name, :string
    field :entities, :string, default: ""
  end

  # Create a new table row, internal only
  defp create(name), do: %Channel{name: name, entities: ""} |> Repo.insert

  # Return the channel row, but avoid creating new rows
  def get(name) do
    row = Channel
    |> where([e], e.name == ^name)
    |> Repo.one

    case row do
      nil ->
        []
      channel ->
        String.split(channel.entities, ",", trim: true)
    end
  end

  # Convert value to database row, create if doesn't exist yet.
  defp to_row(name) when is_binary(name) do
    row = Channel
    |> where([e], e.name == ^name)
    |> Repo.one

    case row do
      nil ->
        {:ok, channel} = create(name)
        channel
      channel ->
        channel
    end
  end

  defp to_row(%Channel{} = channel), do: channel

  # Add uuid to list
  def add(id, uuid) do
    channel = to_row(id)
    entities = String.split(channel.entities, ",", trim: true)
    updated_entities = [uuid | entities]

    set(channel, updated_entities)
  end

  # Remove uuid from list
  def remove(id, uuid) do
    channel = to_row(id)
    entities = String.split(channel.entities, ",", trim: true)
    updated_entities = List.delete(entities, uuid)

    set(channel, updated_entities)
  end

  # Set the new value of the list
  def set(id, updated_entities) do
    channel = to_row(id)
    channel
    |> Ecto.Changeset.cast(%{entities: Enum.join(updated_entities,",")}, [:entities])
    |> Repo.update
  end

  # Empty out all records in the channel (by removing the row because its quicker)
  def clear(id) do
    channel = to_row(id)
    channel
    |> Repo.delete
  end
end