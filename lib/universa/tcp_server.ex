defmodule Universa.TcpServer do
  use Task, restart: :permanent

  # Start a task that runs forever for the server port
  def start_link([]) do
    {:ok, pid} = Task.start_link(__MODULE__, :listen, [])
    Process.register(pid, __MODULE__)
    {:ok, pid}
  end

  # Open the listening port
  def listen do
    {:ok, socket} = :gen_tcp.listen(4000, [
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
    {:ok, client} = :gen_tcp.accept(socket)

    # Create a Terminal with default filters and shell
    {:ok, pid} = DynamicSupervisor.start_child(Universa.TerminalSupervisor, 
      {
        Universa.Terminal, 
        [
          socket: client, 
          filters: [Filter.MCCP, Filter.Telnet, Filter.Ascii], 
          shell: Shell.Authentication
        ]
      }
    )

    # Hand ownership to the newly created Terminal, so it receives messages
    :ok = :gen_tcp.controlling_process(client, pid)

    # Full module name so it automatically uses a newer version if available
    Universa.TcpServer.loop_accept socket
  end
end