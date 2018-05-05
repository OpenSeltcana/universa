defmodule Universa.TcpServer do
  use Task, restart: :permanent

  def start_link([]) do
    {:ok, pid} = Task.start_link(__MODULE__, :accept, [])
    Process.register(pid, __MODULE__)
    {:ok, pid}
  end

  def accept do
    {:ok, socket} = :gen_tcp.listen(4000, [packet: :line, active: true, reuseaddr: true, keepalive: true])

    loop_accept socket
  end

  def loop_accept(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = DynamicSupervisor.start_child(Universa.TerminalSupervisor, {Universa.Terminal, client})
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_accept socket
  end
end