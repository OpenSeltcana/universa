defmodule System.Broadcast do
  use Universa.System

  alias Universa.Event
  alias Universa.Channel

  # Send terminal output events directly to the terminal
  event 50, :broadcast, %Event{
      data: %{
        target: channel,
        event: event
      }
    } do
    Enum.each(Channel.get(channel), fn entity ->
      Event.emit(%Universa.Event{event | target: entity})
    end)
    :ok
  end
end