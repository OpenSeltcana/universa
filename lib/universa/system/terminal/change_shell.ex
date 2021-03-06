defmodule Universa.System.Terminal.ChangeShell do
  alias Universa.Event
  alias Universa.System

  use System

  # Change Terminal's shell at request
  event 99, :terminal, %Event{
    data: %{
      type: :change_shell,
      shell: shell,
      to: terminal
    }
  } do
    GenServer.cast(terminal, {:change_shell, shell})
    :ok
  end
end