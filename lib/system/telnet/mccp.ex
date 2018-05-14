defmodule System.Telnet.MCCP do
  @moduledoc """
  Handles events related to the Mud Client Compression Protocol telnet command.

  Once enabled all server-side communication is zlib compressed.

  Specification is at: http://tintin.sourceforge.net/mccp/
  """

  use Universa.System

  alias Universa.Event

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
    |> Event.emit
  end

  # When asked to start compressing
  event 50, :telnet, %Event{
      data: %{
        command: [255, 253, 86],
        from: terminal
      }
    } do

    zlib = :zlib.open()
    :zlib.deflateInit(zlib, 4)
    :zlib.set_controlling_process(zlib, terminal)
    Universa.Terminal.set(terminal, :telnet_mccp_compressor, zlib)

    # Send confirmation
    task = %Event{
      type: :terminal,
      data: %{
        type: :output,
        template: "telnet/subnegotiate_mccp.eex",
        to: terminal
      }
    }
    |> Event.emit
    Task.await(task)
    Universa.Terminal.set(terminal, :telnet_mccp, true)
  end

  # When asked to stop compressing
  event 50, :telnet, %Event{
      data: %{
        command: [255, 254, 86],
        from: terminal
      }
    } do
    Universa.Terminal.set(terminal, :telnet_mccp, false)

    case Universa.Terminal.get(terminal, :telnet_mccp_compressor) do
      {:ok, zlib} ->
        Universa.Terminal.set(terminal, :telnet_mccp_compressor, nil)
        :zlib.set_controlling_process(zlib, self())
        :zlib.deflateEnd(zlib)
        :zlib.close(zlib)
      _ -> :ok
    end
  end
end