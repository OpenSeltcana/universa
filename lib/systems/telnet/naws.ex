defmodule System.Telnet.Naws do
  use Universa.System

  alias Universa.Event

  # When receiving IAC SB NAWS SEND _ SEND _ IAC SE
  event 50, :telnet, %Event{data: %{command: [255, 250, 31, 0, w, 0, h, 255, 240], from: terminal}} do
    # Store it in the terminal
    Universa.Terminal.set(terminal, :telnet_naws, fn _ -> [width: w, height: h] end)
  end
end