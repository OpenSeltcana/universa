defmodule Universa.System.Location do
  alias Universa.Event
  alias Universa.System
  alias Universa.Location
  alias Universa.Component
  alias Universa.Channel

  use System

  # If location is a string instead of a uuid, update it to a uuid
  event 50, Component.Physical, %Event{
    data: %{
      action: :component_created,
      new: physical
    }
  } do
    location = physical.location
    entity = physical.component_entity

    case is_uuid(location) or location == "void" do
      false ->
        location_uuid = Location.take(location)

        physical
        |> Component.Physical.update(:location, location_uuid)
      true ->
        Channel.add(location, entity)
    end
  end

  # Do the same for component changes
  event 50, Component.Physical, %Event{
    data: %{
      action: :component_changed,
      old: old_physical,
      new: new_physical
    }
  } do
    old_location = old_physical.location
    new_location = new_physical.location
    entity = new_physical.component_entity

    if is_uuid(old_location) do
      Channel.remove(old_location, entity)
    end

    case is_uuid(new_location) or new_location == "void" do
      false ->
        location_uuid = Location.take(new_location)

        new_physical
        |> Component.Physical.update(:location, location_uuid)
      true ->
        Channel.add(new_location, entity)
    end
  end

  defp is_uuid(string) do
    Regex.match?(~r/[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}/, string)
  end
end
