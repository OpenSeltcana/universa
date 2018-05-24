defmodule Universa.System.Terminal do
  alias Universa.Event
  alias Universa.System

  use System

  # Create a Terminal registry at server startup
  event 50, :server, %Event{
    data: %{
      type: :start
    }
  } do
    {:ok, _} =
      Supervisor.start_child(
        Universa.Supervisor,
        Supervisor.child_spec(
          {
            Registry,
            keys: :unique, name: Universa.Registry.Terminal
          },
          id: :registry_terminal
        )
      )

    :ok
  end
end
