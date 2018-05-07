defmodule System.Telnet.Naws do
  @moduledoc """
  Handles events related to the Negotiate About Window Size telnet command.

  Once requested of the client, the client will send its initial window size (in
   rows & cols), then sends updates whenever the window size is changed.

  The updates of the client window size are stored in the `Universa.Terminal` 
  under the key :telnet_naws
  """
  

  use Universa.System

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
        command: [255, 250, 31, 0, w, 0, h, 255, 240],
        from: terminal
      }
    } do
    # Store it in the terminal
    Universa.Terminal.set(terminal, :telnet_naws, fn _ -> [width: w, height: h] end)
  end
end