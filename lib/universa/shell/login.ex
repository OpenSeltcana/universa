defmodule Universa.Shell.Login do
  alias Universa.Shell
  alias Universa.Event
  alias Universa.Account
  alias Universa.Template

  use Shell

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
        username: "",
        uuid: ""
      }
    }
  end

  # When we receive text and we are at the password step (second)
  def input(packet, %{terminal: terminal, shell_state: %{step: :username} = state}) do
    # If player typed "new", send them to the registration shell
    case String.downcase("#{packet}") == "new" do
      true ->
        events = [
          %Event{
            type: :terminal,
            data: %{
              type: :change_shell,
              shell: Shell.Registration,
              to: terminal
            }
          }
        ]

        {events, %{state | step: :registration}}

      false ->
        events = [
          %Event{
            type: :terminal,
            data: %{
              type: :output,
              template: "authentication/ask_password.eex",
              to: terminal
            }
          },
          %Event{
            type: :terminal,
            data: %{
              type: :output,
              template: "telnet/will_echo.eex",
              to: terminal
            }
          }
        ]

        {events, %{state | step: :password, username: String.capitalize("#{packet}")}}
    end
  end

  # When we receive text and we are at the password step (second)
  def input(packet, %{
        terminal: terminal,
        shell_state: %{step: :password, username: username} = state
      }) do
    case Account.login(username, "#{packet}") do
      {:ok, uuid} ->
        events = [
          %Event{
            type: :terminal,
            data: %{
              type: :output,
              template: "authentication/authenticated.eex",
              to: terminal
            }
          },
          %Event{
            type: :terminal,
            data: %{
              type: :output,
              template: "telnet/wont_echo.eex",
              to: terminal
            }
          },
          %Event{
            type: :terminal,
            data: %{
              type: :change_shell,
              shell: Shell.Player,
              to: terminal
            }
          }
        ]

        {events, %{state | step: :authenticated, uuid: uuid}}

      {:error, _} ->
        events = [
          %Event{
            type: :terminal,
            data: %{
              type: :output,
              template: "authentication/ask_password_again.eex",
              to: terminal
            }
          }
        ]

        {events, state}
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
    metadata = Map.get(event.data, :metadata, [])
    {:ok, msg} = Template.fill(template, metadata)

    {msg, state}
  end

  # If we receive anthing other than template requests... Whine about it!
  def output(_, %{shell_state: state}) do
    IO.write("We received spam, truly!?")
    {"", state}
  end

  # Do nothing when we get removed
  def on_unload(%{shell_state: state}), do: {[], state}
end