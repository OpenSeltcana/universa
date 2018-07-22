defmodule Universa.Database.ChannelMember do
  use Universa.Database.Table

  deftable(uuid: "", channel: "", entity: "")
end
