defmodule Universa.TcpServer do
  use Task, restart: :permanent

  alias Universa.TerminalSupervisor
  alias Universa.Terminal
  alias Universa.TcpServer
  alias :gen_tcp, as: TCP

  # Start a task that runs forever for the server port
  def start_link([]) do
    {:ok, pid} = Task.start_link(__MODULE__, :listen, [])
    Process.register(pid, __MODULE__)
    {:ok, pid}
  end

  # Open the listening port
  def listen do
    {:ok, socket} = TCP.listen(4000, [
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
    {:ok, client} = TCP.accept(socket)

    # Create a Terminal with default filters and shell
    {:ok, pid} = DynamicSupervisor.start_child(TerminalSupervisor, 
      {
        Terminal, 
        [
          socket: client, 
          filters: [Universa.Filter.MCCP, Universa.Filter.Telnet, Universa.Filter.Ascii], 
          shell: Universa.Shell.Authentication,
          ssl: false
        ]
      }
    )

    # Hand ownership to the newly created Terminal, so it receives messages
    :ok = TCP.controlling_process(client, pid)

    # Full module name so it automatically uses a newer version if available
    TcpServer.loop_accept socket
  end
end