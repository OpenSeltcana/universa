defmodule Parser.Help do
  use Universa.Parser

  alias Universa.Event

  def parse("help", entity) do
    events = [
      %Event{
        type: :terminal,
        target: entity.uuid,
        data: %{
          type: :output,
          template: "parser/help.eex"
        }
      }
    ]

    {:stop, events}
  end
end