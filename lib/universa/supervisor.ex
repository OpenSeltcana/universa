defmodule Universa.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      # Start the Registry which the `Channel` module uses.
      Supervisor.child_spec({
        Registry,
        keys: :duplicate,
        name: Universa.ChannelRegistry,
        partitions: System.schedulers_online
      }, id: :channel_registry),
      # Start the Registry which the `Location` component uses.
      Supervisor.child_spec({
        Registry,
        keys: :unique,
        name: Universa.LocationRegistry
      }, id: :location_registry),
      # Start a supervisor for all the accept() tasks of the `Server`.
      Supervisor.child_spec({
        Task.Supervisor,
        name: Universa.NetworkSupervisor,
	  }, id: :network_supervisor),
      # Start a dynamic supervisor for all the `Component` `GenServer`'s.
      Supervisor.child_spec(Universa.ComponentSupervisor,
        id: :component_supervisor),
      # Start a dynamic supervisor for all the `System` `GenServer`'s.
      Supervisor.child_spec(Universa.SystemSupervisor,
        id: :system_supervisor),
      # Start the TCP socket listener module `Server`.
      Supervisor.child_spec(Universa.Server,
        id: :network_server),
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
