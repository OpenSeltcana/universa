# Universa

## Example usage

Right now no Systems are added by default, so to get the MOTD, run:
```
$> iex -S mix
Interactive Elixir (1.6.0) - press Ctrl+C to exit (type h() ENTER for help)

16:48:07.038 [info]  Accepting connections on port 2323
iex(1)> Universa.Channel.Server.add_system(Universa.System.Debug)
{:ok, #PID<0.162.0>}
iex(2)> Universa.Channel.Server.add_system(Universa.System.Account)
{:ok, #PID<0.162.0>}
iex(3)> xxxxxxxxxxxx Universa.System.Debug xxxxxxxxx
iex(3)> {{:player_connect, #PID<0.175.0>}, "server:nonode@nohost"}
iex(3)> xxxxxxxxxxxx   END OF INTERCEPT    xxxxxxxxx
iex(3)> xxxxxxxxxxxx Universa.System.Debug xxxxxxxxx
iex(3)> Username Mr. Test
iex(3)> {{:player_input, #PID<0.175.0>, "Mr. Test\r\n"}, "server:nonode@nohost"}
iex(3)> xxxxxxxxxxxx   END OF INTERCEPT    xxxxxxxxx
iex(3)> xxxxxxxxxxxx Universa.System.Debug xxxxxxxxx
iex(3)> Password Never!
iex(3)> {{:player_input, #PID<0.175.0>, "Never!\r\n"}, "server:nonode@nohost"}
iex(3)> xxxxxxxxxxxx   END OF INTERCEPT    xxxxxxxxx
iex(3)> xxxxxxxxxxxx Universa.System.Debug xxxxxxxxx
iex(3)> {{:player_ready, #PID<0.175.0>}, "server:nonode@nohost"}
iex(3)> xxxxxxxxxxxx   END OF INTERCEPT    xxxxxxxxx
iex(3)>
```

## Concepts

`Universa.Channel` is a group of `Universa.Component`'s and `Universa.System`'s.
`Universa.Component` stores properties of any entity.
`Universa.System` handles events sent through `Universa.Channel`.

For example, when someone connects to the server a `Universa.Component.Socket` is made to store the socket for later access and through `Universa.Channel.Server` a `:player_connect` event is sent.

Now if `Universa.System.Account` is added to the `Universa.Channel.Server` (look at #Example Usage how to), it will process the event and send the welcoming message to the socket in the `Universa.Component.Socket` made earlier.
