defmodule Universa.System.Location do
  alias Universa.Event
  alias Universa.System
  alias Universa.Location
  alias Universa.Component
  alias Universa.Channel
  alias Universa.Entity

  use System

  # If location is a string instead of a uuid, update it to a uuid
  event 50, :component, %Event{
    target: entity,
    data: %{
      action: :create,
      key: "location",
      value: %{
        "value" => location
      }
    }
  } do
    if not is_uuid(location) do
      location_uuid = Location.get(location)

      component = Entity.component(entity, "location")
      Component.update(component, %{value: location_uuid})

      Channel.add(location_uuid, entity)
    else
      Channel.add(location, entity)
    end
  end

  # Do the same for component changes
  event 50, :component, %Event{
    target: entity,
    data: %{
      action: :update,
      key: "location",
      old: %{
        "value" => old_location
      },
      new: %{
        "value" => new_location
      }
    }
  } do
    if is_uuid(old_location) do
      Channel.remove(old_location, entity)
    end

    if not is_uuid(new_location) do
      location_uuid = Location.get(new_location)

      component = Entity.component(entity, "location")
      Component.update(component, %{value: location_uuid})

      Channel.add(location_uuid, entity)
    else
      Channel.add(new_location, entity)
    end
  end

  defp is_uuid(string) do
    Regex.match?(~r/[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}/, string)
  end
end
