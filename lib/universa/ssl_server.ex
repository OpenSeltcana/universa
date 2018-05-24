defmodule Universa.SSLServer do
  use Task, restart: :permanent

  alias Universa.TerminalSupervisor
  alias Universa.Terminal
  alias Universa.SSLServer
  alias :ssl, as: SSL

  # Start a task that runs forever for the server port
  def start_link([]) do
    {:ok, pid} = Task.start_link(__MODULE__, :listen, [])
    Process.register(pid, __MODULE__)
    {:ok, pid}
  end

  # Open the listening port
  def listen do
    {:ok, socket} =
      SSL.listen(
        4001,
        certfile: "certificate.pem",
        keyfile: "key.pem",
        packet: :line,
        # Send messages instead of blocking calls
        active: true,
        # To avoid issues when doing quick restarts
        reuseaddr: true,
        # Check periodically if the other side is still alive
        keepalive: true
      )

    loop_accept(socket)
  end

  # This function loops forever, accepting connections endlessly
  def loop_accept(socket) do
    # Wait for a new connection and accept it
    {:ok, client} = SSL.transport_accept(socket)

    # Finish the SSL negotiation
    :ok = SSL.ssl_accept(client)

    # Create a Terminal with default filters and shell
    {:ok, pid} =
      DynamicSupervisor.start_child(TerminalSupervisor, {
        Terminal,
        [
          socket: client,
          filters: [Universa.Filter.MCCP, Universa.Filter.Telnet, Universa.Filter.Ascii],
          shell: Universa.Shell.Authentication,
          ssl: true
        ]
      })

    # Hand ownership to the newly created Terminal, so it receives messages
    :ok = SSL.controlling_process(client, pid)

    # Full module name so it automatically uses a newer version if available
    SSLServer.loop_accept(socket)
  end
end
