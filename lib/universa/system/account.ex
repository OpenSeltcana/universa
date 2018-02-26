defmodule Universa.System.Account do
  use Universa.System

  def handle({:player_connect, terminal}, _channel) do
    # Add the Account Component to the entity when they connect
    uuid = Universa.Component.get_entity_id(terminal)
    {:ok, account} = Universa.Component.LoggingIn.new(uuid)

    # Then send the welcome and login screen
    {:socket, socket} = Universa.Component.get_value(terminal)

    :gen_tcp.send(socket, """
    \x1B[33m      .-  _             _  -.\r
         /   /  .         .  \\   \\ \x1B[35m    .   .     o\r
    \x1B[33m    (   (  (  \x1B[36m (-o-) \x1B[33m  )  )   ) \x1B[35m   |   |,---...    ,,---.,---.,---.,---.\r
    \x1B[33m     \\   \\_ ` \x1B[36m  |x|\x1B[33m   ` _/   /  \x1B[35m   |   ||   || \\  / |---'|    `---.,---|\r
    \x1B[33m      `-      \x1B[36m  |x|\x1B[33m        -`   \x1B[35m   `---'`   '`  `'  `---'`    `---'`---^\r
                  \x1B[36m  |x|\x1B[39m\r
    \r
        Enter your nickname, or the one you'd like if you are new here:\r
    """)

    true
  end

  def handle({:player_input, terminal, message}, _channel) do
    {:socket, socket} = Universa.Component.get_value(terminal)

    uuid = Universa.Component.get_entity_id(terminal)

    %{Universa.Component.LoggingIn => logging_in_pid} = Universa.Channel.Entity.get_types(uuid, [Universa.Component.LoggingIn])

    logging_in = Universa.Component.get_value(logging_in_pid)

    case logging_in[:authentication_step] do
      0 ->
        IO.write("Username #{message}")
        Universa.Component.set_value(logging_in_pid,
          logging_in
          |> Map.put(:authentication_step, 1)
          |> Map.put(:username, String.trim(message)))

        :gen_tcp.send(socket, """
        Seems like you are new here! Please enter a password next:\r
        """)

      1 ->
        IO.write("Password #{message}")
        Universa.Component.remove(logging_in_pid)

        {:ok, account} = Universa.Component.Account.new(uuid)
        Universa.Component.set_value(account, %{username: logging_in[:username]})

        :gen_tcp.send(socket, """
        You are all set #{logging_in[:username]}, enjoy the game!\r
        """)

        Universa.Channel.Server.send({:player_ready, terminal})
    end
  end
end
