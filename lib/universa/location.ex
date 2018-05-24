defmodule Universa.Location do
  use Ecto.Schema

  import Ecto.Query

  alias Universa.Repo
  alias Universa.Location
  alias Universa.Entity
  alias Universa.Channel

  schema "locations" do
    field(:location, :string)
    field(:uuid, :string)
  end

  @spec create(String.t()) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  defp create(location) do
    {:ok, ent} = Entity.create()

    Entity.load_from_file(ent, "location/#{location}")

    Channel.add("locations", ent.uuid)

    %Location{location: location, uuid: ent.uuid} |> Repo.insert()
  end

  @spec get(String.t()) :: String.t()
  def get(location) do
    row =
      Location
      |> where([e], e.location == ^location)
      |> Repo.one()

    case row do
      nil ->
        {:ok, loc} = create(location)
        loc.uuid

      loc ->
        loc.uuid
    end
  end

  @spec destroy(String.t()) :: {:ok} | {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def destroy(location) do
    row =
      Location
      |> where([e], e.location == ^location)
      |> Repo.one()

    case row do
      nil ->
        :ok

      loc ->
        loc
        |> Repo.delete()
    end
  end
end
