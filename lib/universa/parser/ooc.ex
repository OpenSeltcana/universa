defmodule Universa.Parser.OOC do
  alias Universa.Event
  alias Universa.Parser

  use Parser

  def parse("ooc " <> message, entity) do
    events = [
      %Event{
        type: :broadcast,
        data: %{
          target: "online_players",
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