defmodule Universa.System.Account do
  use Universa.System

  require Logger

  auto_subscribe

  capability :player_connect
  def handle({:player_connect, terminal}) do
    # Add the Account Component to the entity when they connect
    uuid = Universa.Component.get_entity_id(terminal)
    {:ok, account} = Universa.Component.LoggingIn.new(uuid)

    # Then send the welcome and login screen
    {:socket, socket} = Universa.Component.get_value(terminal)

    Universa.Channel.Entity.send(uuid, {:terminal_message, terminal, [type: :account_welcome]})
  end

  capability :player_input, [Universa.Component.LoggingIn]
  def handle({:player_input, terminal, message}) do
    {:socket, socket} = Universa.Component.get_value(terminal)

    uuid = Universa.Component.get_entity_id(terminal)

    # If we dont have the login component we stop here
    try do
      %{Universa.Component.LoggingIn => logging_in_pid} = Universa.Channel.Entity.get_types(uuid, [Universa.Component.LoggingIn])

      logging_in = Universa.Component.get_value(logging_in_pid)
      
      case logging_in[:authentication_step] do
	0 ->
          Universa.Component.set_value(logging_in_pid,
            logging_in
            |> Map.put(:authentication_step, 1)
            |> Map.put(:username, String.trim(message)))
	  
          Universa.Channel.Entity.send(uuid, {:terminal_message, terminal, [type: :account_password]})
	  
	1 ->
          Universa.Component.remove(logging_in_pid)
	  
          {:ok, account} = Universa.Component.Account.new(uuid)
          Universa.Component.set_value(account, %{username: logging_in[:username]})
	  
          Universa.Channel.Entity.send(uuid, {:terminal_message, terminal, [type: :account_authenticated, name: logging_in[:username]]})
	  
          Universa.Channel.Server.send({:player_ready, terminal, logging_in[:username]})
	  
	  Logger.debug "Player '#{logging_in[:username]}' signed in on Entity '#{uuid}'"
      end
    rescue
     _ -> false
    end
  end
end
