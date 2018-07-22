defmodule Universa.Parser.Look do
  alias Universa.Event
  alias Universa.Parser
  alias Universa.Channel
  alias Universa.Component

  use Parser

  def parse("look", entity) do
    location = Component.Physical.take(entity).location
    location_physical = case Component.Physical.take(location) do
      nil -> %{name: "void", description: "The void is endless and consumes all."}
      physical -> physical
    end

    contents =
      Channel.members(location)
      |> Enum.flat_map(fn entity ->
        case Component.Physical.take(entity) do
          nil -> [] # Hide things without a physical component
          physical -> [physical.name]
        end
      end)
      |> Enum.join(".\r\n")

    events = [
      %Event{
        type: :terminal,
        target: entity.uuid,
        data: %{
          type: :output,
          template: "parser/look.eex",
          metadata: %{
            location: location_physical,
            contents: contents
          }
        }
      }
    ]

    {:stop, events}
  end
end
