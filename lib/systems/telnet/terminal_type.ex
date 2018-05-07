defmodule Systems.Telnet.TerminalType do
  @moduledoc """
  Handles events related to the Terminal-Type telnet command.

  While Terminal-Type's original purpose seems to have been selecting the 
  client's terminal, between "ANSI", "VT100", et cetera. In MUDs its main 
  purpose appears to be to communicate the client's application like "tintin++" 
  for TinTin++ and "rxvt-unicode-256", or whatever terminal emulator you use for
   linux's telnet.

  The reply of the command is stored in the `Universa.Terminal` under the key
  :telnet_terminal_type
  """
  
  use Universa.System

  alias Universa.Event

  # Tell the client to do terminal type!
  event 50, :telnet, %Event{
      data: %{
        type: :start,
        from: terminal
      }
    } do
    %Event{
      type: :terminal, 
      data: %{
        type: :output,
        template: "telnet/do_terminal_type.eex",
        to: terminal
      }
    }
    |> Universa.Event.emit
  end

  # When client tells us it does terminal type
  event 50, :telnet, %Event{
      data: %{
        command: [255, 251, 24],
        from: terminal
      }
    } do
    # Ask the client to send us the terminal type
    %Event{
      type: :terminal,
      data: %{
        type: :output,
        template: "telnet/send_terminal_type.eex",
        to: terminal
      }
    }
    |> Universa.Event.emit
  end

  # When receiving the client's terminal type
  event 50, :telnet, %Event{
      data: %{
        command: [255, 250, 24, 0 | client], 
        from: terminal
      }
    } do
    # cut off the IAC SE at the end to get the terminal type
    terminal_type = Enum.take(client, length(client)-2)

    # Store it in the terminal
    Universa.Terminal.set(terminal, :telnet_terminal_type, fn _ -> terminal_type end)
  end
end