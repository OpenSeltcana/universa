defmodule Universa do
  use Application

  alias Universa.Event
  alias Universa.Repo
  alias Universa.SystemAgent
  alias Universa.TcpServer
  alias Universa.SSLServer
  alias Universa.TerminalSupervisor
  alias Universa.EventSupervisor

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Repo,
      SystemAgent,
      TcpServer,
      #SSLServer,
      {DynamicSupervisor, name: TerminalSupervisor, strategy: :one_for_one},
      {Task.Supervisor, name: EventSupervisor}
    ]

    opts = [strategy: :one_for_one, name: Universa.Supervisor]
    result = Supervisor.start_link(children, opts)

    %Event{
      type: :server,
      data: %{
        type: :start
      }
    } |> Event.emit

    result
  end
end