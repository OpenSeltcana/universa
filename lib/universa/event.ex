defmodule Universa.Event do
  defstruct source: nil, target: nil, type: nil, data: %{}

  # For each event, start a Task under Universa.EventSupervisor running run/1
  def emit(%Universa.Event{} = event) do
    Task.Supervisor.async_nolink(
      Universa.EventSupervisor,
      Universa.Event,
      :run,
      [event]
    )
    :ok
  end

  # If we received a list of events, just run emit on each individually
  def emit(events) when is_list(events) do
    Enum.each(events, fn event ->
      emit(event)
    end)
  end

  # Take our event, get a list of all systems registered to our event type,
  # then run every single one of them with our event
  def run(event) do
    case Universa.SystemAgent.systems(event.type) do
      {:ok, systems} ->
        Enum.each(systems, fn {order, system} ->
          apply(system, :event, [order, event.type, event])
        end)
        :ok
      _ -> :error
    end
  end
end