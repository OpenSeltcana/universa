defmodule Universa.System.Terminal do
  use Universa.System

  @compile :nowarn_unused_vars

  capability :terminal_message, [Universa.Component.Terminal]
  def handle({:terminal_message, terminal, message}) do
    case Universa.Component.get_value(terminal) do
      # If its a socket listener, send it to templating and then the port
      {:socket, socket} ->
        IO.inspect(message)
        :gen_tcp.send(socket,
                      apply(Universa.Template, message[:type], [message])
                      |> String.replace("\n", "\r\n")
                      |> String.replace("#1#", "\x1B[30m")
                      |> String.replace("#2#", "\x1B[31m")
                      |> String.replace("#3#", "\x1B[32m")
                      |> String.replace("#4#", "\x1B[33m")
                      |> String.replace("#5#", "\x1B[34m")
                      |> String.replace("#6#", "\x1B[35m")
                      |> String.replace("#7#", "\x1B[36m")
                      |> String.replace("#8#", "\x1B[37m")
                      |> String.replace("#r#", "\x1B[37m"))
      _ -> false # Do nothing
    end
  end
end
