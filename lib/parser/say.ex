defmodule Parser.Say do
  use Universa.Parser

  alias Universa.Event

  def parse("say " <> message, entity) do
    events = [
      %Event{
        type: :terminal,
        source: entity.uuid,
        data: %{
          type: :output,
          template: "parser/say.eex",
          metadata: [
            from: entity.uuid,
            message: message,
            to: nil
          ]
        }
      },
      %Event{
        type: :terminal,
        target: entity.uuid,
        data: %{
          type: :output,
          template: "parser/say.eex",
          metadata: %{
            from: entity.uuid,
            to: nil,
            message: message
          }
        }
      }
    ]

    {:stop, events}
  end
end