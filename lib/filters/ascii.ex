defmodule Filter.Ascii do
  use Universa.Filter

  def get(packet, _state), do: Enum.filter(packet, fn char -> (char >= 20 and char <= 126) or char == 12 end)

  def put(packet, _state), do: packet
end