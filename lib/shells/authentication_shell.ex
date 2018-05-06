defmodule Shell.AuthenticationShell do
  use Universa.Shell

  alias Universa.Event

  def on_load(state) do
    # TODO: Send all telnet commands only AFTER confirming client supports telnet
    events = [
      %Event{type: :telnet, data: %{type: :start, from: state.terminal}}
    ]

    {events, state}
  end

  def input(packet, state) do
    events = [%Event{type: :terminal, data: %{type: :input, msg: packet}}]

    {events, state}
  end

  # Raw templates get send unchanged (usually for telnet commands)
  def output(%Event{type: :terminal, data: %{type: :output, template: :raw, metadata: msg}} = event, state) do
    {msg, state}
  end

  # All other messsages are templates that get filled in
  def output(%Event{type: :terminal, data: %{type: :output, template: template}} = event, state) do
    metadata = Map.get(event.data, :metadata, [])
    {:ok, msg} = Universa.Template.fill(template, metadata)

    {msg, state}
  end

  def output(_, state) do
    IO.write "We received spam, truly!?"
    {"", state}
  end

  def on_unload(state), do: {[], state}
end