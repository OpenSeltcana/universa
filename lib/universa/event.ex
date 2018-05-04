defmodule Universa.Event do
  defstruct source: nil, target: nil, type: nil, data: %{}

  def emit(%Universa.Event{} = event) do
    Task.async(Universa.Event, :run, [event])
    :ok
  end

  def run(event) do
    case Universa.SystemAgent.systems(event.type) do
      {:ok, systems} ->
        Enum.each(systems, fn system ->
          apply(system, :event, [event.type, event])
        end)
        :ok
      _ -> :error
    end
  end
end