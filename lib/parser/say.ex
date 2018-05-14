defmodule Parser.Say do
  use Universa.Parser

  alias Universa.Event

  def parse("say " <> message, entity) do
    events = [
      %Event{
        type: :speech,
        source: entity.uuid,
        data: %{
          message: message,
          volume: 70 # 70 dB is normal voice according to engineeringtoolbox.com
        }
      }
    ]

    {:stop, events}
  end
end