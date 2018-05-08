defmodule Shell.Player do
  use Universa.Shell

  alias Universa.Event

  # PLACEHOLDER: Just send a creepy hi message, thats all
  def on_load(%{terminal: terminal, shell_state: %{step: :authenticated, username: username}} = state) do
    # Create the terminal registry if it doesn't exist yet
    if is_nil(Process.whereis(Universa.Registry.Terminal)) do
      Supervisor.start_child(Universa.Supervisor, 
        Supervisor.child_spec({
          Registry,
          keys: :unique,
          name: Universa.Registry.Terminal
        }, id: :registry_terminal)
      )
    end

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

    {:ok, ent} = Universa.Entity.create

    # Use custom registry, because we cant store PIDs in ecto in a safe way.
    {:ok, _} = Registry.register(Universa.Registry.Terminal, ent.uuid, nil)

    # Add a list of default parsers for now
    Universa.Component.create(ent, "parser", %{
      list: [
        [50, Parser.Help]
      ]
    })

    {
      events,
      %{
        uuid: ent.uuid
      }
    }
  end

  # 
  def input(packet, %{terminal: terminal, shell_state: %{uuid: uuid} = state}) do
    ent = Universa.Entity.uuid(uuid)

    parsers = ent
    |> Universa.Entity.component("parser")

    case Enum.any?(parsers.value["list"], fn [_order, parser] ->
      apply(String.to_existing_atom(parser), :parse, ["#{packet}", ent])
    end) do
      true -> {[], state}
      false -> {
        [
          %Event{
            type: :terminal,
            data: %{
              type: :output,
              template: "parser/not_found.eex",
              to: terminal
            }
          }
        ],
        state}
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

    {:ok, msg} = Universa.Template.fill(template, metadata)
    {:ok, prompt_msg} = Universa.Template.fill("player/prompt.eex", %{msg: msg})

    {prompt_msg, state}
  end

  # If we receive anthing other than template requests... Whine about it!
  def output(_, %{shell_state: state}) do
    IO.write "We received spam, truly!?"
    {"", state}
  end

  # Destroy our entity after we go squish
  def on_unload(%{shell_state: %{uuid: uuid} = state}) do
    Universa.Entity.uuid(uuid)
    |> Universa.Entity.destroy

    Registry.unregister(Universa.Registry.Terminal, uuid)

    {[], state}
  end
end