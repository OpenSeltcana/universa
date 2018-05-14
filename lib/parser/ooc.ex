defmodule Parser.OOC do
  use Universa.Parser

  alias Universa.Event

  def parse("ooc " <> message, entity) do
    events = [
      %Event{
        type: :broadcast,
        data: %{
          target: "players",
          event: %Event{
            type: :terminal,
            source: entity.uuid,
            data: %{
              type: :output,
              template: "parser/ooc.eex",
              metadata: %{
                from: entity.uuid,
                message: message
              }
            }
          }
        }
      }
    ]

    {:stop, events}
  end
end