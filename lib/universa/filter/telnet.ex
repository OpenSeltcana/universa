defmodule Universa.Filter.Telnet do
  alias Universa.Filter
  alias Universa.Event

  use Filter

  def get(packet, state) do
    {text, telnet} = filter_telnet(packet)

    events =
      Enum.map(telnet, fn command ->
        %Event{type: :telnet, data: %{from: state.terminal, command: command}}
      end)

    {text, events}
  end

  def put(packet, _state), do: {packet, []}

  defp filter_telnet(input) do
    translations = fn chars ->
      case chars do
        [255] -> :IAC
        [255, 240] -> :SE
        [255, 250] -> :SB
        [255, 251] -> :WILL
        [255, 252] -> :WONT
        [255, 253] -> :DO
        [255, 254] -> :DONT
        _ -> :UNK
      end
    end

    {mask, _} =
      Enum.map_reduce(input, false, fn char, set ->
        case set do
          # If not doing telnet, do this
          false ->
            # This is IAC, move to telnet code
            if char == 255 do
              {nil, {[char]}}
            else
              {char, false}
            end

          # If we are in subnegotiation
          {0, chars} ->
            # If we read an IAC, move to code just below
            if char == 255 do
              {nil, {1, chars ++ [char]}}
              # Else just keep adding the byte to our list of bytes so far
            else
              {nil, {0, chars ++ [char]}}
            end

          {1, chars} ->
            case char do
              # IAC SE, end subnegotation
              240 ->
                {chars ++ [char], false}

              # In subnegotiation IAC IAC means one 255
              255 ->
                {nil, {0, chars}}

              # Write all other characters, even if this should never happen
              _ ->
                {nil, {0, chars ++ [char]}}
            end

          # If we read an IAC, start parsing the next byte
          {chars} ->
            translation = translations.(chars ++ [char])
            # Move to subnegotiation code
            if translation == :SB do
              {nil, {0, chars ++ [char]}}
            else
              # If this is any of will, wont, do, dont, read the next byte too
              if not (translation in [:WILL, :WONT, :DO, :DONT]) do
                {chars ++ [char], false}
                # If not, read the byte after IAC and exit telnet mode
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