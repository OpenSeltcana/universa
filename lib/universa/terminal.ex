defmodule Universa.Terminal do
  use GenServer

  alias Universa.Event

  def start_link([socket: socket, filters: filters, shell: shell]), 
    do: GenServer.start_link(__MODULE__, %{socket: socket, filters: filters, shell: shell})

  def init(%{socket: socket, filters: filters, shell: shell}) do
    state = apply(shell, :on_load, [%{
      terminal: self(),
      socket: socket,
      shell: shell,
      filters: filters
    }])
    {:ok, state}
  end

  ## Client Functions

  def emit(event, pid) do 
    GenServer.cast(pid, {:send, event})
  end

  def get(pid, key), do: GenServer.call(pid, {:get, key})

  def set(pid, key, value), do: GenServer.cast(pid, {:set, key, value})

  ## Server Callbacks

  # Something needs to read something out of us!
  def handle_call({:get, key}, _pid, state) do
    {:reply, Map.fetch(state, key), state}
  end

  # Something needs to store something inside us!
  def handle_cast({:set, key, value}, state) do
    {:noreply, Map.update(state, key, nil, value)}
  end

  # Player received something
  def handle_cast({:send, event}, %{filters: filters, shell: shell} = state) do
    IO.inspect {"Outgoing:", event}
    {packet, new_state} = apply(shell, :output, [event, state])
    msg = run_filters(packet, :put, state, Enum.reverse(filters))

    :gen_tcp.send(state.socket, msg)

    {:noreply, new_state}
  end

  # Player typed something
  def handle_info({:tcp, socket, msg}, %{filters: filters, shell: shell} = state) do
    filtered_msg = run_filters(msg, :get, state, filters)

    {events, new_state} = apply(shell, :input, [filtered_msg, state])

    Enum.each(events, fn event -> Event.emit(event) end)

    {:noreply, new_state}
  end

  # Socket disconnected, kill the Shell and Terminal
  def handle_info({:tcp_closed, _socket}, %{shell: shell} = state) do
    {events, new_state} = apply(shell, :on_unload, [state])

    Enum.each(events, fn event -> Event.emit(event) end)

    {:stop, :normal, new_state}
  end

  # Don't crash when we receive other messages (Erlang likes to send those.)
  def handle_info(_, state), do: {:noreply, state}

  defp run_filters(msg, _fun, _state, []), do: msg

  defp run_filters(msg, fun, state, [filter | others]) do
    apply(filter, fun, [msg, state])
    |> run_filters(fun, state, others)
  end
end