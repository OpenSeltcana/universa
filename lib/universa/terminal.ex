defmodule Universa.Terminal do
  use GenServer

  alias Universa.Entity
  alias Universa.Event

  def start_link(socket), do: GenServer.start_link(__MODULE__, %{socket: socket})

  def init(%{socket: socket}) do
    {:ok, ent} = Entity.create

    %Event{type: :terminal, source: ent.uuid, data: %{type: :connect}}
    |> Event.emit

    {:ok, %{uuid: ent.uuid, socket: socket}}
  end

  ## Server Callbacks

  # Player typed something
  def handle_info({:tcp, socket, msg}, %{uuid: uuid} = state) do
    %Event{type: :terminal, source: uuid, data: %{type: :input, msg: msg}}
    |> Event.emit

    {:noreply, state}
  end

  # Socket disconnected, kill the Terminal
  def handle_info({:tcp_closed, socket}, %{uuid: uuid} = state) do
    %Event{type: :terminal, source: uuid, data: %{type: :disconnect}}
    |> Event.emit

    # Clean up our entity
    Entity.uuid(uuid)
    |> Entity.destroy

    {:stop, :normal, state}
  end
end