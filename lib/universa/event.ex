defmodule Universa.Event do
  defstruct source: nil, target: nil, type: nil, data: %{}

  alias Universa.Event
  alias Universa.EventSupervisor
  alias Universa.SystemAgent

  # For each event, start a Task under Universa.EventSupervisor running run/1
  @spec emit(map) :: {:ok, Task.t()}
  def emit(%Event{} = event) do
    {:ok, Task.Supervisor.async_nolink(EventSupervisor, Event, :run, [event])}
  end

  # If we received a list of events, just run emit on each individually
  @spec emit_all(list(map)) :: :ok
  def emit_all(events) do
    Enum.each(events, fn event ->
      emit(event)
    end)

    :ok
  end

  # Take our event, get a list of all systems registered to our event type,
  # then run every single one of them with our event
  @spec run(map) :: :ok | :error
  def run(event) do
    case SystemAgent.systems(event.type) do
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
