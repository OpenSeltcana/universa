defmodule Universa.Location do
  use Ecto.Schema

  import Ecto.Query

  alias Universa.Repo
  alias Universa.Location
  alias Universa.Entity
  alias Universa.Channel

  schema "locations" do
    field :location, :string
    field :uuid, :string
  end

  defp create(location) do
    {:ok, ent} = Entity.create

    Entity.load_from_file(ent, "location/#{location}")

    Channel.add("locations", ent.uuid)

    %Location{location: location, uuid: ent.uuid} |> Repo.insert
  end

  def get(location) do
    row = Location
    |> where([e], e.location == ^location)
    |> Repo.one

    case row do
      nil ->
        {:ok, loc} = create(location)
        loc.uuid
      loc ->
        loc.uuid
    end
  end

  def destroy(location) do
    row = Location
    |> where([e], e.location == ^location)
    |> Repo.one

    case row do
      nil ->
        :ok
      loc ->
        loc
        |> Repo.delete
    end
  end
end