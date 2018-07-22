defmodule Universa.System.Speech do
  alias Universa.Event
  alias Universa.System
  alias Universa.Component

  use System

  event 50, :speech, %Event{
    source: source,
    data: %{
      message: message,
      volume: _db
    }
  } do
    # TODO: Work out volumes and ranges and locations
    location = Component.Physical.take(source).location
    [
      %Event{
        type: :broadcast,
        data: %{
          target: location,
          event: %Event{
            type: :terminal,
            source: source,
            data: %{
              type: :output,
              template: "parser/say.eex",
              metadata: %{
                from: source,
                to: nil,
                message: message
              }
            }
          }
        }
      }
    ]
    |> Event.emit_all()
  end
end
