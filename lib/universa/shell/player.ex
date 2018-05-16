defmodule Universa.Shell.Player do
  alias Universa.Shell
  alias Universa.Event
  alias Universa.Channel
  alias Universa.Template
  alias Universa.Parser
  alias Universa.Entity

  use Shell

  # PLACEHOLDER: Just send a creepy hi message, thats all
  def on_load(%{terminal: terminal, shell_state: %{step: :authenticated, username: username, uuid: uuid}} = state) do

    {w, h} = Map.get(state, :telnet_naws, {0, 0})
    terminal_type = Map.get(state, :telnet_terminal_type, "UNKNOWN")

    events = [
      %Event{
        type: :terminal,
        data: %{
          type: :output,
          template: "player/welcome.eex",
          metadata: %{
            username: username,
            terminal_type: terminal_type,
            w: w,
            h: h
          },
          to: terminal
        }
      }
    ]

    Channel.add("online_players", uuid)

    # Use custom registry, because we cant store PIDs in ecto in a safe way.
    {:ok, _} = Registry.register(Universa.Registry.Terminal, uuid, nil)

    {
      events,
      %{
        uuid: uuid
      }
    }
  end

  # Player typed something
  def input(packet, %{terminal: terminal, shell_state: %{uuid: uuid} = state}) do
    ent = Entity.uuid(uuid)

    parsers = ent
    |> Entity.component("parser")

    case Parser.each("#{packet}", ent, parsers.value["list"]) do
      {:stop, events} -> {events, state}
      {:keep_going, events} -> 
        {
          events ++ [
            %Event{
              type: :terminal,
              data: %{
                type: :output,
                template: "parser/not_found.eex",
                to: terminal
              }
            }
          ],
          state
        }
    end
  end

  # All incoming messsages from the game are templates that get filled in
  def output(
      %Event{
        type: :terminal,
        data: %{
          type: :output,
          template: template
        }
      } = event, 
      %{shell_state: state}
    ) do
    metadata = Map.get(event.data, :metadata, %{})

    {:ok, msg} = Template.fill(template, metadata)
    {:ok, prompt_msg} = Template.fill("player/prompt.eex", %{msg: msg})

    {prompt_msg, state}
  end

  # If we receive anthing other than template requests... Whine about it!
  def output(_, %{shell_state: state}) do
    IO.write "We received spam, truly!?"
    {"", state}
  end

  # Destroy our entity after we go squish
  def on_unload(%{shell_state: %{uuid: uuid} = state}) do
    Registry.unregister(Universa.Registry.Terminal, uuid)

    Channel.remove("online_players", uuid)

    {[], state}
  end
end