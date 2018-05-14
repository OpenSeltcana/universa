defmodule System.Telnet.MSSP do
  @moduledoc """
  Handles events related to the Mud Server Status Protocol telnet command.

  It is meant to list accurate and up-to-date information for crawlers.

  Specification is at: http://tintin.sourceforge.net/mssp/
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
        template: "telnet/will_mssp.eex",
        to: terminal
      }
    }
    |> Event.emit
  end

  # When receiving an update of the client's window size
  event 50, :telnet, %Event{
      data: %{
        command: [255, 251, 70],
        from: terminal
      }
    } do
    # Send up to date information
    %Event{
      type: :terminal,
      data: %{
        type: :output,
        template: "telnet/subnegotiate_mssp.eex",
        to: terminal,
        metadata: %{
          name: "Universa",
          players: length(Universa.Channel.get("players")),
          uptime: -1 # TODO: Figure out where to keep track of this
        }
      }
    }
    |> Event.emit
  end
end