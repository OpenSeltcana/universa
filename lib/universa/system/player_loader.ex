defmodule Universa.System.PlayerLoader do
  use Universa.System

  auto_subscribe

  def handle({:player_ready, terminal, name}) do
    uuid = Universa.Component.get_entity_id(terminal)
      
    Universa.ComponentImporter.import(uuid, "players/new.yml")
  end
end
