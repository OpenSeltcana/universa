defmodule Universa do
  alias Universa.Event

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # # Start the Registry which the `Channel` module uses.
      # Supervisor.child_spec({
      #   Registry,
      #   keys: :duplicate,
      #   name: Universa.ChannelRegistry,
      #   partitions: System.schedulers_online
      # }, id: :channel_registry),
      # # Start the Registry which the `Location` component uses.
      # Supervisor.child_spec({
      #   Registry,
      #   keys: :unique,
      #   name: Universa.LocationRegistry
      # }, id: :location_registry),
      # # Start a supervisor for all the accept() tasks of the `Server`.
      # Supervisor.child_spec({
      #   Task.Supervisor,
      #   name: Universa.NetworkSupervisor,
      # }, id: :network_supervisor),
      # # Start a dynamic supervisor for all the `Component` `GenServer`'s.
      # Supervisor.child_spec(Universa.ComponentSupervisor,
      #   id: :component_supervisor),
      # # Start a dynamic supervisor for all the `System` `GenServer`'s.
      # Supervisor.child_spec(Universa.SystemSupervisor,
      #   id: :system_supervisor),
      # # Start the TCP socket listener module `Server`.
      # Supervisor.child_spec(Universa.Server,
      #   id: :network_server),
      {Task.Supervisor, name: Universa.EventSupervisor},
      Universa.TcpServer,
      Universa.Database.PeriodicSave,
      Universa.System,
      {DynamicSupervisor, name: Universa.TerminalSupervisor, strategy: :one_for_one},
      {Registry, keys: :unique, name: Universa.Registry.Terminal},
    ]

    opts = [strategy: :one_for_one, name: Universa.Supervisor]
    result = Supervisor.start_link(children, opts)

    Universa.System.reload()

    :ok =
          %Event{
            type: :server,
            data: %{action: :startup}
          }
          |> Event.emit()
    
    result
  end

  # Helper module to get configuration variables
  def get_config(option, default) do
    Application.get_env(:universa, option, default)
  end
end
