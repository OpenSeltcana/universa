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

  def send(pid, event), do: GenServer.cast(pid, {:send, event})

  def get(pid), do: GenServer.call(pid, :get)

  def set(pid, state), do: GenServer.call(pid, {:set, state})

  ## Server Callbacks

  # Not reall sure about these yet
  def handle_info({_, :ok}, state), do: {:noreply, state}
  def handle_info({_, :error}, state), do: {:noreply, state}
  def handle_info({:DOWN, _, :process, _, :normal}, state), do: {:noreply, state}

  # Player received something
  def handle_cast({:send, event}, %{filters: filters, shell: shell} = state) do
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

  # Socket disconnected, kill the Terminal
  def handle_info({:tcp_closed, _socket}, state) do
    {:stop, :normal, state}
  end

  defp run_filters(msg, _fun, _state, []), do: msg

  defp run_filters(msg, fun, state, [filter | others]) do
    apply(filter, fun, [msg, state])
    |> run_filters(fun, state, others)
  end
end