defmodule Universa.Channel.Server do
  # The server channel is custom and does not use Universa.Channel

  defp channel_identifier, do: "server"

  def add_system(module) do
    Universa.Channel.add_system(channel_identifier(), module)
  end

  def send(message) do
    Universa.Channel.send(channel_identifier(), message)
  end

  def rem_system(module) do
    Universa.Channel.rem_system(channel_identifier(), module)
  end
end
