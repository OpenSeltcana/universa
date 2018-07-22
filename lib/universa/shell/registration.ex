defmodule Universa.Shell.Registration do
  alias Universa.Event
  alias Universa.Account
  alias Universa.Component
  alias Universa.Channel
  alias Universa.Template
  alias Universa.Entity
  alias Universa.Shell

  use Shell

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
      }
    ]

    {
      events,
      %{
        step: :username,
        username: "",
        password: "",
        uuid: nil
      }
    }
  end

  def input(packet, %{terminal: terminal, shell_state: %{step: :username} = state}) do
    username = String.capitalize("#{packet}")

    events = [
      %Event{
        type: :terminal,
        data: %{
          type: :output,
          template: "registration/ask_username_confirmation.eex",
          metadata: %{
            username: username
          },
          to: terminal
        }
      }
    ]

    {events, %{state | step: :confirm_username, username: username}}
  end

  def input(packet, %{terminal: terminal, shell_state: %{step: :confirm_username} = state}) do
    packet_lowered = String.downcase("#{packet}")

    if packet_lowered == "yes" or packet_lowered == "y" do
      events = [
        %Event{
          type: :terminal,
          data: %{
            type: :output,
            template: "registration/ask_password.eex",
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

      {events, %{state | step: :password, password: packet}}
    else
      events = [
        %Event{
          type: :terminal,
          data: %{
            type: :output,
            template: "registration/ask_username_again.eex",
            to: terminal
          }
        }
      ]

      {events, %{state | step: :username}}
    end
  end

  def input(packet, %{terminal: terminal, shell_state: %{step: :password} = state}) do
    events = [
      %Event{
        type: :terminal,
        data: %{
          type: :output,
          template: "registration/ask_password_confirmation.eex",
          to: terminal
        }
      }
    ]

    {events, %{state | step: :confirm_password, password: packet}}
  end

  def input(packet, %{
        terminal: terminal,
        shell_state: %{step: :confirm_password, username: username, password: password} = state
      }) do
    case packet == password do
      true ->
        ent = Entity.create()

        Account.create(username, "#{password}", ent.uuid)

        Component.Physical.create(ent, %{
          name: username,
          location: "start"
        })

        # Add a list of default parsers for now
        Component.Player.create(ent, %{
          account: username,
          parsers: Universa.get_config(:parsers, [
            [50, Universa.Parser.Help],
            [50, Universa.Parser.Say],
            [50, Universa.Parser.OOC],
            [50, Universa.Parser.Look]
          ])
        })

        Channel.add("players", ent.uuid)

        events = [
          %Event{
            type: :terminal,
            data: %{
              type: :output,
              template: "registration/complete.eex",
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

        {events, %{state | step: :authenticated, uuid: ent.uuid}}

      false ->
        events = [
          %Event{
            type: :terminal,
            data: %{
              type: :output,
              template: "registration/ask_password_again.eex",
              to: terminal
            }
          }
        ]

        {events, %{state | step: :password}}
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
