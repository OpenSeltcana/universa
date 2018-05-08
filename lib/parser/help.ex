defmodule Parser.Help do
  use Universa.Parser

  alias Universa.Event

  def parse("help", entity) do
    %Event{
      type: :terminal,
      target: entity.uuid,
      data: %{
        type: :output,
        template: "parser/help.eex"
      }
    }
    |> Event.emit

    true
  end
end