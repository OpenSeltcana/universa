defmodule Universa.System.StartupCleanup do
  alias Universa.System
  alias Universa.Event
  alias Universa.Channel

  use System

  # Empty things that should be empty when the server is (re)started
  event 50, :server, %Event{
    data: %{action: :startup}
  } do
    Channel.clear("online_players")

    :ok
  end
end
