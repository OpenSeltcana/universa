defmodule Universa.Event do
  defstruct source: nil, target: nil, type: nil, data: %{}

  alias Universa.Event
  alias Universa.EventSupervisor
  alias Universa.System

  # For each event, start a Task under Universa.EventSupervisor running run/1
  @spec emit(%Event{}) :: :ok
  def emit(%Event{} = event) do
    %Task{} = Task.Supervisor.async_nolink(EventSupervisor, Event, :run, [event])

    :ok
  end

  @spec emit_blocking(%Event{}, integer) :: :ok
  def emit_blocking(%Event{} = event, timeout \\ 5000) do
    Task.Supervisor.async_nolink(EventSupervisor, Event, :run, [event])
    |> Task.await(timeout)

    :ok
  end

  # If we received a list of events, just run emit on each individually
  @spec emit_all(list(%Event{})) :: :ok
  def emit_all(events) do
    Enum.each(events, fn event ->
      emit(event)
    end)

    :ok
  end

  # Take our event, get a list of all systems registered to our event type,
  # then run every single one of them with our event
  @spec run(%Event{}) :: :ok | :error
  def run(%Event{} = event) do
    case System.list(event.type) do
      {:ok, systems} ->
        Enum.each(systems, fn {order, system} ->
          apply(system, :event, [order, event.type, event])
        end)

        :ok

      _ ->
        :error
    end
  end
end
