defmodule Universa.System.MOTD do
  use Universa.System

  def handle({:player_connect, component}, _channel) do
    Universa.Component.get_value(component)
    |> :gen_tcp.send("""
    \x1B[33m      .-  _             _  -.\r
         /   /  .         .  \\   \\ \x1B[35m    .   .     o\r
    \x1B[33m    (   (  (  \x1B[36m (-o-) \x1B[33m  )  )   ) \x1B[35m   |   |,---...    ,,---.,---.,---.,---.\r
    \x1B[33m     \\   \\_ ` \x1B[36m  |x|\x1B[33m   ` _/   /  \x1B[35m   |   ||   || \\  / |---'|    `---.,---|\r
    \x1B[33m      `-      \x1B[36m  |x|\x1B[33m        -`   \x1B[35m   `---'`   '`  `'  `---'`    `---'`---^\r
                  \x1B[36m  |x|\x1B[39m\r
    \r
        Enter your nickname:\r
    """)
    true
  end
end
