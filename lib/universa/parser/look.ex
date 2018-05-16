defmodule Universa.Parser.Look do
  alias Universa.Event
  alias Universa.Parser
  alias Universa.Entity
  alias Universa.Channel

  use Parser

  def parse("look", entity) do
    location = Entity.component(entity, "location").value["value"]
    location_name = Entity.component(location, "name")
    contents = Channel.get(location)
    |> Enum.map(fn entity -> 
      Entity.component(entity, "name").value["value"]
    end)
    |> Enum.join(".\r\n")

    if not is_nil(location_name) do
      events = [
        %Event{
          type: :terminal,
          target: entity.uuid,
          data: %{
            type: :output,
            template: "parser/look.eex",
            metadata: %{
              name: location_name.value["value"],
              contents: contents
            }
          }
        }
      ]

      {:stop, events}
    else
      {:keep_going, []}
    end
  end
end