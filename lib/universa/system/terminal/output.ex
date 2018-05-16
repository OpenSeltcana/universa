defmodule Universa.System.Terminal.Output do
  alias Universa.Event
  alias Universa.System

  use System

  # Send terminal output events directly to the terminal
  event 99, :terminal, %Event{data: %{type: :output, to: terminal}} = event do
    GenServer.cast(terminal, {:send, event})
    :ok
  end

  # Send entity output events to terminal by looking it up
  event 99, :terminal, %Event{data: %{type: :output}, target: uuid} = event do
    # Can't do this in a guard because of the = event part
    if not is_nil(uuid) do
      case Registry.lookup(Universa.Registry.Terminal, uuid) do
        [{terminal, nil}] -> # We found the terminal connected to that uuid
          GenServer.cast(terminal, {:send, event})
          :ok
        [] -> # We did not find the terminal
          :error
      end
    else
      :error
    end
  end
end