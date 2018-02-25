defmodule Universa.Server do
  use Task, restart: :permanent

  require Logger

  def start_link(_opts) do
    Task.start_link(__MODULE__, :accept, [2323])
  end

  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port,
                      [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(Universa.NetworkSupervisor,
                                             fn -> first_serve(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp first_serve(socket) do
    {:ok, component} = Universa.Component.Socket.new
    Universa.Component.set_value(component, socket)
    Universa.Channel.Server.send({:player_connect, component})

    serve(socket, component)
  end

  defp serve(socket, component) do
    case read_line(socket) do
      {:ok, data} ->
        Universa.Channel.Server.send({:player_input, component, data})

        serve(socket, component)
      {:error, :closed} ->
        Universa.Channel.Server.send({:player_disconnect, component})
    end
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end
end
