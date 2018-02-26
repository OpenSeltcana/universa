defmodule Universa do
  use Application

  def start(_type, _args) do
    result = Universa.Supervisor.start_link(name: Universa.Supervisor)

    Universa.System.auto_subscribe_systems

    result
  end
end
