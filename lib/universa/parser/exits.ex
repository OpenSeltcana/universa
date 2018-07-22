defmodule Universa.Parser.Exits do
  alias Universa.Event
  alias Universa.Parser
  alias Universa.Component
  alias Universa.Location

  use Parser

  def parse(input, entity) do
    location = Component.Physical.take(entity).location
    location_exits = Component.Location.take(location).exits

    case Enum.any?(location_exits, fn [name, uuid] ->
      case input == name do
        true ->
          %Event{
            type: :broadcast,
            data: %{
              target: location,
              event: %Event{
                type: :terminal,
                source: entity.uuid,
                data: %{
                  type: :output,
                  template: "parser/exit_out.eex",
                  metadata: %{
                    from: entity.uuid,
                    exit: name
                  }
                }
              }
            }
          }
          |> Event.emit()

          Component.Physical.take(entity)
          |> Component.Physical.update(:location, uuid)

          %Event{
            type: :broadcast,
            data: %{
              target: Location.take(uuid),
              event: %Event{
                type: :terminal,
                source: entity.uuid,
                data: %{
                  type: :output,
                  template: "parser/exit_in.eex",
                  metadata: %{
                    from: entity.uuid,
                    exit: name
                  }
                }
              }
            }
          }
          |> Event.emit()

          true
        false -> false
      end
    end) do 
      true -> {:stop, []}
      false -> {:keep_going, []}
    end
  end
end
