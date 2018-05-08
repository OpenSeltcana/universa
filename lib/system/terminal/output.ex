defmodule System.Terminal.Output do
  use Universa.System

  alias Universa.Event

  # Send terminal output events directly to the terminal
  event 99, :terminal, %Event{data: %{type: :output, to: terminal}} = event do
    GenServer.cast(terminal, {:send, event})
    :ok
  end

  # Send entity output events to terminal by looking it up
  event 99, :terminal, %Event{data: %{type: :output}, target: uuid} = event do
    # Can't do this in a guard because of the = event part
    if not is_nil(uuid) do
      [{terminal, nil}] = Registry.lookup(Universa.Registry.Terminal, uuid)
      GenServer.cast(terminal, {:send, event})
      :ok
    else
      :error
    end
  end
end