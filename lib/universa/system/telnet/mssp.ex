defmodule Universa.System.Telnet.MSSP do
  @moduledoc """
  Handles events related to the Mud Server Status Protocol telnet command.

  It is meant to list accurate and up-to-date information for crawlers.

  Specification is at: http://tintin.sourceforge.net/mssp/
  """

  alias Universa.Event
  alias Universa.System
  alias Universa.Channel
  alias :application, as: Application

  use System

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
    |> Event.emit()
  end

  # When MSSP request is received, send the message!
  event 50, :telnet, %Event{
    data: %{
      command: [255, 253, 70],
      from: terminal
    }
  } do
    # Collect information
    {:ok, version} = Application.get_key(:universa, :vsn)
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
          "PLAYERS" => length(Channel.members("players")),
          # TODO: Figure out where to keep track of this
          "UPTIME" => -1
        }
      }
    }
    |> Event.emit()
  end
end
