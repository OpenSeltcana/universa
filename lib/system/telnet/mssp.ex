defmodule System.Telnet.MSSP do
  @moduledoc """
  Handles events related to the Mud Server Status Protocol telnet command.

  It is meant to list accurate and up-to-date information for crawlers.

  Specification is at: http://tintin.sourceforge.net/mssp/
  """

  use Universa.System

  alias Universa.Event

  # When telnet is started, notify we support MSSP!
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

  # When MSSP request is received, send the message!
  event 50, :telnet, %Event{
      data: %{
        command: [255, 253, 70],
        from: terminal
      }
    } do
    # Collect information
    {:ok, version} = :application.get_key(:universa, :vsn)
    # Send up to date information
    %Event{
      type: :terminal,
      data: %{
        type: :output,
        template: "telnet/subnegotiate_mssp.eex",
        to: terminal,
        metadata: %{
          "NAME" => "Universa",
          "PORT" => 4000,
          "CODEBASE" => "Universa #{List.to_string(version)}",
          "FAMILY" => "Custom",
          "ANSI" => 1,
          "MCCP" => 1,
          "PLAYERS" => length(Universa.Channel.get("players")),
          "UPTIME" => -1 # TODO: Figure out where to keep track of this
        }
      }
    }
    |> Event.emit
  end
end