defmodule Universa.Terminal do
  use GenServer

  alias Universa.Entity
  alias Universa.Event

  def start_link(socket), do: GenServer.start_link(__MODULE__, %{socket: socket})

  # Create our entit and 
  def init(%{socket: socket}) do
    {:ok, ent} = Entity.create

    %Event{type: :terminal, source: ent.uuid, data: %{type: :connect}}
    |> Event.emit

    # Tell client we support TELNET and want window size and client type
    :gen_tcp.send(socket, "\xff\xfd\x1f\xff\xfd\x18")

    {:ok, %{
      uuid: ent.uuid,
      socket: socket,
      telnet: %{
        binary: false,
        echo: false,
        naws: {80,24},
        ttype: "UNKNOWN"
      },
    }}
  end

  ## Server Callbacks

  # Not reall sure about these yet
  def handle_info({_, :ok}, state), do: {:noreply, state}
  def handle_info({:DOWN, _, :process, _, :normal}, state), do: {:noreply, state}

  # Player typed something
  def handle_info({:tcp, socket, msg}, %{uuid: uuid, telnet: telnet} = state) do
    {message, telnet_reply, new_telnet} = filter_telnet(msg, telnet)
        
    if telnet_reply != "", do: :gen_tcp.send(socket, telnet_reply)


    %Event{type: :terminal, source: uuid, data: %{type: :input, msg: message}}
    |> Event.emit

    {:noreply, %{state | telnet: new_telnet}}
  end

  # Socket disconnected, kill the Terminal
  def handle_info({:tcp_closed, _socket}, %{uuid: uuid} = state) do
    %Event{type: :terminal, source: uuid, data: %{type: :disconnect}}
    |> Event.emit

    # Clean up our entity
    Entity.uuid(uuid)
    |> Entity.destroy

    {:stop, :normal, state}
  end

  ## Telnet filtering:

  defp filter_telnet(input, state) do
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
              end) ++ translation, false}
            else
              {nil, {chars ++ [char]}}
            end
          end
      end
    end)

    telnet = Enum.filter(mask, &is_list(&1))
    text = Enum.filter(mask, &is_number(&1))

    new_state = 
      state
      |> parse_subnegotiation(Enum.filter(mask, &is_tuple(&1)))
      |> parse_telnet(telnet)

    {"#{text}", reply_telnet(telnet), new_state}
  end

  defp parse_subnegotiation(state, []), do: state

  defp parse_subnegotiation(state, cmds) do
    [{cmd} | tail] = cmds

    parse_subnegotiation(case cmd do
      [31,0,w,0,h] -> Map.update!(state, :naws, fn _ -> {w,h} end)
      [24,0 | terminal] -> Map.update!(state, :ttype, fn _ -> "#{terminal}" end)
      _ -> state
    end, tail)
  end

  defp parse_telnet(state, []), do: state

  defp parse_telnet(state, cmds) do
    [cmd | tail] = cmds

    parse_telnet(case cmd do
      [:IAC, :DONT, :BINARY] -> Map.update!(state, :binary, fn _ -> false end)
      [:IAC, :DO, :BINARY] -> Map.update!(state, :binary, fn _ -> true end)
      [:IAC, :DONT, :ECHO] -> Map.update!(state, :echo, fn _ -> false end)
      [:IAC, :DO, :ECHO] -> Map.update!(state, :echo, fn _ -> true end)
      _ -> state
    end, tail)
  end

  defp reply_telnet(state, []), do: state

  defp reply_telnet(state, cmds) do
    [cmd | tail] = cmds

    reply_telnet(case cmd do
      [:IAC, :DONT, :BINARY] -> "#{state}\xff\xfc\x01"
      [:IAC, :DO, :BINARY] -> "#{state}\xff\xfb\x01"
      [:IAC, :DONT, :ECHO] -> "#{state}\xff\xfc\x02"
      [:IAC, :DO, :ECHO] -> "#{state}\xff\xfb\x02"
      [:IAC, :WILL| :TTYPE] -> "#{state}\xff\xfa\x18\x01\xff\xf0"
      _ -> state
    end, tail)
  end

  defp reply_telnet(cmds), do: reply_telnet("", cmds)
end