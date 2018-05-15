defmodule System.Location do
  use Universa.System

  alias Universa.Event

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
      location_uuid = Universa.Location.get(location)

      component = Universa.Entity.component(entity, "location")
      Universa.Component.update(component, %{value: location_uuid})

      Universa.Channel.add(location_uuid, entity)
    else
      Universa.Channel.add(location, entity)
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
      Universa.Channel.remove(old_location, entity)
    end

    if not is_uuid(new_location) do
      location_uuid = Universa.Location.get(new_location)

      component = Universa.Entity.component(entity, "location")
      Universa.Component.update(component, %{value: location_uuid})

      Universa.Channel.add(location_uuid, entity)
    else
      Universa.Channel.add(new_location, entity)
    end
  end

  defp is_uuid(string) do
    Regex.match?(~r/[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}/, string)
  end
end