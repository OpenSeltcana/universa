defmodule Universa.Location do
  alias Universa.Database
  alias Universa.Entity
  alias Universa.Channel
  
  defp create(name, entity) do
    location = %Database.Location{
      name: name,
      entity: entity
    }

    Database.run(fn ->
      Database.write(location)
    end)

    :ok
  end

  def take(name) do
    case Database.run(fn ->
      Database.read(Database.Location, name: name)
    end) do
      nil -> # Create the location if it doesn't exist yet
        entity = Entity.from_file("location/#{name}")

        create(name, entity.uuid)

        Channel.add("locations", entity.uuid)

        entity.uuid
      entity -> entity.entity # return the entity if it does exist
    end
  end
end

