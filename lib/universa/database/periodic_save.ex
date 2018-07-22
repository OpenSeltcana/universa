defmodule Universa.Database.PeriodicSave do
  @moduledoc """
  Process that dumps the database to disk at a set interval.

  This module is responsibile for sending the messages:

  `22:27:33.018 [info]  [database]  Saving database...`

  `22:27:33.020 [info]  [database]  Doing final save of database.`

  The first message pops up at a set interval, the second message pops up when
  the process is gracefully shutting down. It means that 
  `Universa.Database.save/0` is being run, storing the current state of the
  database from memory to disk.
  """

  # Give us a lot of time to do the final save.
  use GenServer, shutdown: 20_000

  require Logger

  alias Universa.Database

  @doc """
  Starts this module under a supervisor.

  See `GenServer.start_link/2`
  """
  def start_link([]) do
    GenServer.start_link(__MODULE__, [])
  end

  @impl true
  def init(_) do
    Process.flag(:trap_exit, true)
    Process.send_after(self(), :save, 60000)
    {:ok, {}}
  end

  @impl true
  def handle_info(:save, state) do
    :ok =
      Logger.info(fn ->
        "[database]  Saving database..."
      end)

    Database.save()
    Process.send_after(self(), :save, 60000)
    {:noreply, state}
  end

  @impl true
  def terminate(_, _) do
    :ok =
      Logger.info(fn ->
        "[database]  Doing final save of database."
      end)

    Database.save()
  end
end
