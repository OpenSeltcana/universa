defmodule Systems.Telnet.TerminalType do
  use Universa.System

  alias Universa.Event

  # When receiving IAC WILL TERMINAL-TYPE
  event 50, :telnet, %Event{data: %{command: [255, 251, 24], from: terminal}} do
    IO.inspect terminal
    # Send IAC SB TERMINAL-TYPE SEND IAC SE
    %Event{type: :terminal, data: %{type: :output, msg: "\xff\xfa\x18\x01\xff\xf0"}}
    |> Universa.Terminal.emit(terminal)
  end

  # When receiving IAC SB TERMINAL-TYPE IS _ IAC SE
  event 50, :telnet, %Event{data: %{command: [255, 250, 24, 0 | client], from: terminal}} do
    # cut off the IAC SE to get the terminal type
    terminal_type = Enum.take(client, length(client)-2)

    # Store it in the terminal
    Universa.Terminal.set(terminal, :telnet_terminal_type, fn _ -> terminal_type end)
  end
end