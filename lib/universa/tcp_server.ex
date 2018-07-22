defmodule Universa.TcpServer do
  use Task, restart: :permanent

  alias Universa.TerminalSupervisor
  alias Universa.Terminal
  alias Universa.TcpServer
  alias :gen_tcp, as: TCP

  # Start a task that runs forever for the server port
  @spec start_link([]) :: {:ok, pid}
  def start_link([]) do
    {:ok, pid} = Task.start_link(__MODULE__, :listen, [])
    Process.register(pid, __MODULE__)
    {:ok, pid}
  end

  # Open the listening port
  def listen do
    {:ok, socket} =
      TCP.listen(
        Universa.get_config(:port, 4000),
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
    {:ok, client} = TCP.accept(socket)

    # Create a Terminal with default filters and shell
    {:ok, pid} =
      DynamicSupervisor.start_child(TerminalSupervisor, {
        Terminal,
        [
          socket: client,
          filters: Universa.get_config(:filters, [Universa.Filter.MCCP, Universa.Filter.Telnet, Universa.Filter.Ascii]),
          shell: Universa.get_config(:shell, Universa.Shell.Login),
          ssl: false
        ]
      })

    # Hand ownership to the newly created Terminal, so it receives messages
    :ok = TCP.controlling_process(client, pid)

    # Full module name so it automatically uses a newer version if available
    TcpServer.loop_accept(socket)
  end
end