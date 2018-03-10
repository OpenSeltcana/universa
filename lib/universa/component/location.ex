defmodule Universa.Component.Location do
  use Universa.Component

  default_value nil

  # Fancy override to replace string values with PIDs by looking them up
  def new(uuid, value) when is_list(value) do
    case Registry.lookup(Universa.LocationRegistry, value) do
      [{pid, _}] -> __MODULE__.new(uuid, value)
      [] ->
 	# TODO: Actually load locations
        {:ok, location} = Universa.Component.Location.new()
        Universa.Component.register(location, Universa.LocationRegistry, value)
	room_uuid = Universa.Component.get_entity_id(location)
	Universa.ComponentImporter.import(room_uuid, value)
        __MODULE__.new(uuid, location)
    end
  end
end
