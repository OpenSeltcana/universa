defmodule Shell.AuthenticationShell do
  use Universa.Shell

  alias Universa.Event

  # When this shell is loaded ask for telnet features and send a welcome message
  def on_load(%{terminal: terminal}) do
    # TODO: Send all telnet commands only AFTER confirming client supports telnet
    events = [
      %Event{
        type: :telnet,
        data: %{
          type: :start,
          from: terminal
        }
      },
      %Event{
        type: :terminal,
        data: %{
          type: :output,
          template: "authentication/welcome.eex",
          to: terminal
        }
      }
    ]

    {
      events,
      %{
        step: :username,
        username: ""
      }
    }
  end

  # When we receive text and we are at the username step (first)
  def input(packet, %{shell_state: %{step: :username} = state}) do
    events = [
      %Event{
        type: :terminal,
        data: %{
          type: :output, 
          template: "authentication/ask_password.eex"
        }
      }
    ]

    {events, %{state | step: :password, username: packet}}
  end

  # When we receive text and we are at the password step (second)
  def input(packet, %{shell_state: %{step: :password} = state}) do
    events = [
      %Event{
        type: :terminal,
        data: %{
          type: :input,
          msg: packet
        }
      }
    ]

    {events, state}
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