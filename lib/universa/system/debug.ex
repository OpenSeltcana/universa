defmodule Universa.System.Debug do
  use Universa.System

  def handle(event, channel) do
    IO.write "xxxxxxxxxxxx Universa.System.Debug xxxxxxxxx\r\n"
    IO.inspect {event, channel}
    IO.write "xxxxxxxxxxxx   END OF INTERCEPT    xxxxxxxxx\r\n"
    false
  end
end
