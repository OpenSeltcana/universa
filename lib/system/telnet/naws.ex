defmodule System.Telnet.Naws do
  @moduledoc """
  Handles events related to the Negotiate About Window Size telnet command.

  Once requested of the client, the client will send its initial window size (in
   rows & cols), then sends updates whenever the window size is changed.

  The updates of the client window size are stored in the `Universa.Terminal` 
  under the key :telnet_naws
  """
  

  use Universa.System

  # For shifting things 8 bits
  use Bitwise

  alias Universa.Event

  # Tell the client to do Native Window Size updates!
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
        template: "telnet/do_naws.eex",
        to: terminal
      }
    }
    |> Universa.Event.emit
  end

  # When receiving an update of the client's window size
  event 50, :telnet, %Event{
      data: %{
        command: [255, 250, 31, w1, w0, h1, h0, 255, 240],
        from: terminal
      }
    } do
    # Store it in the terminal
    Universa.Terminal.set(terminal, :telnet_naws, {(w1 <<< 8) + w0, (h1 <<< 8) + h0})
  end
end