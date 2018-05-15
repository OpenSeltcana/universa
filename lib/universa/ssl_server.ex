defmodule Universa.SSLServer do
  use Task, restart: :permanent

  alias :ssl, as: SSL

  # Start a task that runs forever for the server port
  def start_link([]) do
    {:ok, pid} = Task.start_link(__MODULE__, :listen, [])
    Process.register(pid, __MODULE__)
    {:ok, pid}
  end

  # Open the listening port
  def listen do
    {:ok, socket} = SSL.listen(4001, [
        certfile: "certificate.pem",
        keyfile: "key.pem",
        packet: :line, 
        active: true, # Send messages instead of blocking calls
        reuseaddr: true, # To avoid issues when doing quick restarts
        keepalive: true # Check periodically if the other side is still alive
      ]
    )

    loop_accept socket
  end

  # This function loops forever, accepting connections endlessly
  def loop_accept(socket) do
    # Wait for a new connection and accept it
    {:ok, client} = SSL.transport_accept(socket)

    # Finish the SSL negotiation
    :ok = SSL.ssl_accept(client)

    # Create a Terminal with default filters and shell
    {:ok, pid} = DynamicSupervisor.start_child(Universa.TerminalSupervisor, 
      {
        Universa.Terminal, 
        [
          socket: client, 
          filters: [Filter.MCCP, Filter.Telnet, Filter.Ascii], 
          shell: Shell.Authentication,
          ssl: true
        ]
      }
    )

    # Hand ownership to the newly created Terminal, so it receives messages
    :ok = SSL.controlling_process(client, pid)

    # Full module name so it automatically uses a newer version if available
    Universa.SSLServer.loop_accept socket
  end
end