defmodule Shell.Registration do
  use Universa.Shell

  alias Universa.Event

  # PLACEHOLDER: Just send people to the PlayerShell
  def on_load(%{terminal: terminal, shell_state: %{step: :registration}}) do
    events = [
      %Event{
        type: :terminal,
        data: %{
          type: :output,
          template: "registration/welcome.eex",
          to: terminal
        }
      },
      # Because we are a placeholder, send them straight towards PlayerShell
      %Event{
        type: :terminal,
        data: %{
          type: :change_shell,
          shell: Shell.Player,
          to: terminal
        }
      }
    ]

    {
      events,
      # Deceive the next shell in thinking the player just logged in
      %{
        username: "Guest",
        step: :authenticated
      }
    }
  end

  # PLACEHOLDER: Do nothing when we receive a message from the player
  def input(_packet, %{shell_state: state}), do: {[], state}

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
    metadata = Map.get(event.data, :metadata, [])
    {:ok, msg} = Universa.Template.fill(template, metadata)

    {msg, state}
  end

  # If we receive anthing other than template requests... Whine about it!
  def output(_, %{shell_state: state}) do
    IO.write "We received spam, truly!?"
    {"", state}
  end

  # Do nothing when we get removed
  def on_unload(%{shell_state: state}), do: {[], state}
end