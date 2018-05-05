defmodule Shell.LoginTerminal do
  use Universa.Shell

  alias Universa.Event

  def on_load(state) do
    # Tell client we support TELNET and want window size and client type
    :gen_tcp.send(state.socket, "\xff\xfd\x1f\xff\xfd\x18")
    state
  end

  def input(packet, state) do
    events = [%Event{type: :terminal, data: %{type: :input, msg: packet}}]
    

    {events, state}
  end

  def on_unload(state), do: {[], state}
end