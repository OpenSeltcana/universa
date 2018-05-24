defmodule Universa.System.Telnet.MCCP do
  @moduledoc """
  Handles events related to the Mud Client Compression Protocol telnet command.

  Once enabled all server-side communication is zlib compressed.

  Specification is at: http://tintin.sourceforge.net/mccp/
  """

  alias Universa.System
  alias Universa.Event
  alias Universa.Terminal
  alias :zlib, as: ZLib

  use System

  # Tell the client we support MCCP!
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
        template: "telnet/will_mccp.eex",
        to: terminal
      }
    }
    |> Event.emit()
  end

  # When asked to start compressing
  event 50, :telnet, %Event{
    data: %{
      command: [255, 253, 86],
      from: terminal
    }
  } do
    zlib = ZLib.open()
    ZLib.deflateInit(zlib, 4)
    ZLib.set_controlling_process(zlib, terminal)
    Terminal.set(terminal, :telnet_mccp_compressor, zlib)

    # Send confirmation
    GenServer.cast(terminal,
     {:send, 
      %Event{
        type: :terminal,
        data: %{
          type: :output,
          template: "telnet/subnegotiate_mccp.eex",
          to: terminal
        }
      }
    })

    Terminal.set(terminal, :telnet_mccp, true)
  end

  # When asked to stop compressing
  event 50, :telnet, %Event{
    data: %{
      command: [255, 254, 86],
      from: terminal
    }
  } do
    Terminal.set(terminal, :telnet_mccp, false)

    case Terminal.get(terminal, :telnet_mccp_compressor) do
      {:ok, zlib} ->
        Terminal.set(terminal, :telnet_mccp_compressor, nil)
        ZLib.set_controlling_process(zlib, self())
        ZLib.deflateEnd(zlib)
        ZLib.close(zlib)

      _ ->
        :ok
    end
  end
end
