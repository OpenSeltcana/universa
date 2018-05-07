defmodule System.Terminal.Output do
  use Universa.System

  alias Universa.Event

  # Send terminal output events directly to the terminal
  event 99, :terminal, %Event{data: %{type: :output, to: terminal}} = event do
    GenServer.cast(terminal, {:send, event})
    :ok
  end
end