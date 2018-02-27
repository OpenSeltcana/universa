defmodule Universa.System.Debug do
  use Universa.System

  def handle(event) do
    IO.write "xxxxxxxxxxxx Universa.System.Debug xxxxxxxxx\r\n"
    IO.inspect event
    IO.write "xxxxxxxxxxxx   END OF INTERCEPT    xxxxxxxxx\r\n"
  end
end
