defmodule Systems.Telnet.TerminalType do
  use Universa.System

  alias Universa.Event

  # Tell the client to do terminal type!
  event 50, :telnet, %Event{data: %{type: :start, from: terminal}} do
    %Event{type: :terminal, data: %{type: :output, template: "telnet/do_terminal_type.eex"}}
    |> Universa.Terminal.emit(terminal)
  end

  # When client tells us it does terminal type
  event 50, :telnet, %Event{data: %{command: [255, 251, 24], from: terminal}} do
    # Ask the client to send us the terminal type
    %Event{type: :terminal, data: %{type: :output, template: "telnet/send_terminal_type.eex"}}
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