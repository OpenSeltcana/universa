defmodule System.Telnet.Naws do
  use Universa.System

  alias Universa.Event

  # Tell the client to do Native Window Size updates!
  event 50, :telnet, %Event{data: %{type: :start, from: terminal}} do
    %Event{type: :terminal, data: %{type: :output, template: "telnet/do_naws.eex"}}
    |> Universa.Terminal.emit(terminal)
  end

  # When receiving IAC SB NAWS SEND _ SEND _ IAC SE
  event 50, :telnet, %Event{data: %{command: [255, 250, 31, 0, w, 0, h, 255, 240], from: terminal}} do
    # Store it in the terminal
    Universa.Terminal.set(terminal, :telnet_naws, fn _ -> [width: w, height: h] end)
  end
end