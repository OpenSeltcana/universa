defmodule Universa.Speech do
  use Universa.System

  alias Universa.Event

  event 50, :speech, %Event{
      source: source,
      data: %{
        message: message,
        volume: _db
      }
    } do
    # TODO: Work out volumes and ranges and locations
    [
      %Event{
        type: :terminal,
        target: source,
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
    ] |> Event.emit
  end
end