defmodule Universa do
  use Application

  def start(_type, _args) do
    Universa.Supervisor.start_link(name: Universa.Supervisor)
  end
end
