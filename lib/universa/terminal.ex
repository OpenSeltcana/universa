defmodule Universa.Terminal do
  use GenServer

  alias Universa.Event
  alias :gen_tcp, as: TCP
  alias :ssl, as: SSL

  def start_link([socket: socket, filters: filters, shell: shell, ssl: ssl]), 
    do: GenServer.start_link(__MODULE__, %{socket: socket, filters: filters, shell: shell, ssl: ssl})

  def init(%{socket: socket, filters: filters, shell: shell, ssl: ssl}) do
    state = %{
      terminal: self(),
      socket: socket,
      shell: shell,
      shell_state: %{},
      filters: filters,
      ssl: ssl
    }

    {events, new_state} = apply(shell, :on_load, [state])

    Enum.each(events, fn event -> Event.emit(event) end)

    {:ok, %{state | shell_state: new_state}}
  end 

  ## Client Functions

  def get(pid, key), do: GenServer.call(pid, {:get, key})

  def set(pid, key, value), do: GenServer.cast(pid, {:set, key, value})

  ## Server Callbacks

  # Something needs to read something out of us!
  def handle_call({:get, key}, _pid, state) do
    {:reply, Map.fetch(state, key), state}
  end

  # Something needs to store something inside us!
  def handle_cast({:set, key, func}, state) when is_function(func) do
    {:noreply, Map.update(state, key, func.(nil), func)}
  end

  def handle_cast({:set, key, nil}, state) do
    {:noreply, Map.delete(state, key)}
  end

  def handle_cast({:set, key, value}, state) do
    {:noreply, Map.update(state, key, value, fn _ -> value end)}
  end

  # Shell is being switched out for another
  def handle_cast({:change_shell, shell_new}, %{shell: shell_old} = state_old) do
    {old_events, shel_state_transition} = apply(shell_old, :on_unload, [state_old])

    Event.emit(old_events)

    {new_events, shell_state_new} = apply(shell_new, :on_load, [
      %{state_old | shell_state: shel_state_transition}
    ])

    Event.emit(new_events)

    {:noreply, %{state_old | shell: shell_new, shell_state: shell_state_new}}
  end

  # Player received something
  def handle_cast({:send, event}, %{filters: filters, shell: shell, socket: socket, ssl: ssl} = state) do
    {packet, new_state} = apply(shell, :output, [event, state])
    {unfiltered_msg, unfilter_events} = run_filters(packet, [], :put, state, Enum.reverse(filters))

    if ssl do
      SSL.send(socket, unfiltered_msg)
    else
      TCP.send(socket, unfiltered_msg)
    end

    Event.emit(unfilter_events)

    {:noreply, %{state | shell_state: new_state}}
  end

  # Player typed something
  def handle_info({:ssl, _socket, msg}, state), do: handle_info({:tcp, nil, msg}, state)

  def handle_info({:tcp, _socket, msg}, %{filters: filters, shell: shell} = state) do
    {filtered_msg, filter_events} = run_filters(msg, [], :get, state, filters)

    Enum.each(filter_events, fn event -> Event.emit(event) end)

    if length(filtered_msg) > 0 do
      {events, new_state} = apply(shell, :input, [filtered_msg, state])

      Event.emit(events)

      {:noreply, %{state | shell_state: new_state}}
    else
      {:noreply, state}
    end
  end

  # Socket disconnected, kill the Shell and Terminal
  def handle_info({:ssl_closed, _socket}, state), do: handle_info({:tcp_closed, nil}, state)

  def handle_info({:tcp_closed, _socket}, %{shell: shell} = state) do
    {events, new_state} = apply(shell, :on_unload, [state])

    Enum.each(events, fn event -> Event.emit(event) end)

    {:stop, :normal, %{state | shell_state: new_state}}
  end

  # Don't crash when we receive other messages (Erlang likes to send those.)
  def handle_info(msg, state), do: {:noreply, state}

  defp run_filters(msg, events, _fun, _state, []), do: {msg, events}

  defp run_filters(msg, events, fun, state, [filter | others]) do
    {new_msg, new_events} = apply(filter, fun, [msg, state])
    run_filters(new_msg, new_events ++ events, fun, state, others)
  end
end