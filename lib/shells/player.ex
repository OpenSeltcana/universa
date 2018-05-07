defmodule Shell.Player do
  use Universa.Shell

  alias Universa.Event

  # PLACEHOLDER: Just send a creepy hi message, thats all
  def on_load(%{terminal: terminal, shell_state: %{step: :authenticated, username: username}} = state) do
    {w, h} = Map.get(state, :telnet_naws, {0, 0})

    events = [
      %Event{
        type: :terminal,
        data: %{
          type: :output,
          template: "player/welcome.eex",
          metadata: %{
            username: username,
            terminal_type: Map.get(state, :telnet_terminal_type, "UNKNOWN"),
            w: w,
            h: h
          },
          to: terminal
        }
      }
    ]

    {:ok, ent} = Universa.Entity.create

    {
      events,
      %{
        uuid: ent.uuid
      }
    }
  end

  # 
  def input(packet, %{shell_state: state}) do
    # TODO: Add parsing logic here!

    {[], state}
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

    {[], state}
  end
end