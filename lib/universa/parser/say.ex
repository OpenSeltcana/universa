defmodule Universa.Parser.Say do
  alias Universa.Parser
  alias Universa.Event

  use Parser

  def parse("say " <> message, entity) do
    events = [
      %Event{
        type: :speech,
        source: entity.uuid,
        data: %{
          message: message,
          # 70 dB is normal voice according to engineeringtoolbox.com
          volume: 70
        }
      }
    ]

    {:stop, events}
  end
end
