defmodule Universa.System.Terminal do
  use Universa.System

  @compile :nowarn_unused_vars

  @fg [
    black:   "\x1B[30m",
    red:     "\x1B[31m",
    green:   "\x1B[32m",
    yellow:  "\x1B[33m",
    blue:    "\x1B[34m",
    purple:  "\x1B[35m",
    cyan:    "\x1B[36m",
    white:   "\x1B[37m",
    reset:   "\x1B[39m",
  ]
  @bg [
    black:   "\x1B[40m",
    red:     "\x1B[41m",
    green:   "\x1B[42m",
    yellow:  "\x1B[43m",
    blue:    "\x1B[44m",
    purple:  "\x1B[45m",
    cyan:    "\x1B[46m",
    white:   "\x1B[47m",
    reset:   "\x1B[49m",
  ]

  capability :terminal_message, [Universa.Component.Terminal]
  def handle({:terminal_message, terminal, message}) do
    case Universa.Component.get_value(terminal) do
      # If its a socket listener, send it to templating and then the port
      {:socket, socket} ->
        :gen_tcp.send(socket,
                      apply(Universa.Template, message[:type], [message,
                                                                @fg,
                                                                @bg])
                      |> String.replace("\n", "\r\n"))
      _ -> false # Do nothing
    end
  end
end
