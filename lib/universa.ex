defmodule Universa do
  use Application

  def start(_type, _args) do
    # Start a supervisor which starts all our needed services.
    result = Universa.Supervisor.start_link(name: Universa.Supervisor)

    # Assign all `System`'s with the auto_subscribe flag to the server channel.
    #Universa.System.auto_start_systems

    result
  end
end
