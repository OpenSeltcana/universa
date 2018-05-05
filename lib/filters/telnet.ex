defmodule Filter.Telnet do
  use Universa.Filter

  alias Universa.Event

  def get(packet, state) do
    {text, telnet} = filter_telnet(packet)

    Enum.each(telnet, fn command ->
      %Event{type: :telnet, data: %{from: state.terminal, command: command}}
      |> Event.emit
    end)

    text
  end

  def put(packet, _state), do: packet

  defp filter_telnet(input) do
    translations = fn(chars) ->
      case chars do
        [255] -> :IAC
        [255,240] -> :SE
        [255,241] -> :NOP
        [255,250] -> :SB
        [255,251] -> :WILL
        [255,252] -> :WONT
        [255,253] -> :DO
        [255,254] -> :DONT
        [255,x,1] when x in 251..254 -> :BINARY
        [255,x,2] when x in 251..254 -> :ECHO
        [255,x,24] when x in 251..254 -> :TTYPE
        [255,x,31] when x in 251..254 -> :NAWS
        _ -> :UNK
      end
    end

    {mask, _} = Enum.map_reduce(input, false, fn(char, set) ->
      case set do
        false ->
          if char == 255 do
            {nil, {[char]}}
          else
            # filter out non-readable except newlines
            if (char >= 20 and char <= 126) or char == 12 do
              {char, false}
            else
              {nil, false}
            end
          end
        {0, chars} ->
          if char == 255 do
            {nil, {1, chars ++ [char]}}
          else
            {nil, {0, chars ++ [char]}}
          end
        {1, chars} ->
          if char == 240 do
            {{Enum.take(chars, length(chars)-1)}, false}
          else
            {nil, {0, chars ++ [char]}}
          end
        {chars} ->
          translation = translations.(chars ++ [char])
          if translation == :SB do
            {nil, {0, []}}
          else
            if not translation in [:WILL,:WONT,:DO,:DONT] do
              {Enum.map(1..length(chars), fn x ->
                translations.(Enum.take(chars, x))
              end) ++ [translation], false}
            else
              {nil, {chars ++ [char]}}
            end
          end
      end
    end)

    telnet = Enum.filter(mask, &is_list(&1))
    text = Enum.filter(mask, &is_number(&1))

    {text, telnet}
  end
end