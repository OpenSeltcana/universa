defmodule Universa do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Universa.Repo,
      Universa.SystemAgent,
      Universa.TcpServer,
      #Universa.SSLServer,
      {DynamicSupervisor, name: Universa.TerminalSupervisor, strategy: :one_for_one},
      {Task.Supervisor, name: Universa.EventSupervisor}
    ]

    opts = [strategy: :one_for_one, name: Universa.Supervisor]
    Supervisor.start_link(children, opts)
  end
end