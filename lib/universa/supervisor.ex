defmodule Universa.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      Supervisor.child_spec({
        Registry,
        keys: :duplicate,
        name: Universa.ChannelRegistry,
        partitions: System.schedulers_online
      }, id: :channel_registry),
      Supervisor.child_spec({
        Task.Supervisor,
        name: Universa.SystemSupervisor,
      }, id: :system_supervisor),
      Supervisor.child_spec({
        Task.Supervisor,
        name: Universa.NetworkSupervisor,
      }, id: :network_supervisor),
      Supervisor.child_spec(Universa.ComponentSupervisor,
        id: :component_supervisor),
      Supervisor.child_spec(Universa.Server,
        id: :network_server),
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
