defmodule Universa.Parser.Help do
  alias Universa.Event
  alias Universa.Parser

  use Parser

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