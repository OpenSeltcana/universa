defmodule Universa.Channel do
  alias Universa.Database

  @type channel :: String.t() | atom
  @type entities :: [String.t()] | String.t()
  @type entity :: String.t()

  @doc "Add `entity` to `channel`"
  @spec add(channel, entities) :: :ok
  def add(channel, [] = entities) do
    Database.run(fn ->
      entities
      |> Enum.each(fn entity ->
        Database.write(%Universa.Database.ChannelMember{
          uuid: UUID.uuid4(),
          channel: channel,
          entity: entity
        })
      end)
    end)

    :ok
  end

  def add(channel, entity) do
    Database.run(fn ->
      Database.write(%Universa.Database.ChannelMember{
        uuid: UUID.uuid4(),
        channel: channel,
        entity: entity
      })
    end)

    :ok
  end

  @doc "Remove `entity` from `channel`"
  @spec remove(channel, entity) :: :ok
  def remove(channel, entity) do
    Database.run(fn ->
      Database.find(
        Universa.Database.ChannelMember,
        channel: channel,
        entity: entity
      )
      |> Enum.each(fn channelmember ->
        Database.delete(channelmember)
      end)
    end)

    :ok
  end

  # TODO: Index channel property and use the index instead of find
  @doc "Retrieve all entities that are a member of this `channel`"
  @spec members(channel) :: list(map)
  def members(channel) do
    Database.run(fn ->
      Database.find(
        Universa.Database.ChannelMember,
        channel: channel
      )
    end)
    |> Enum.map(fn channel_member -> channel_member.entity end)
  end

  # TODO: Index channel property and use the index instead of find
  @doc "Retrieve all channels this `entity` is a member of"
  @spec memberof(entity) :: list(map)
  def memberof(entity) do
    Database.run(fn ->
      Database.find(
        Universa.Database.ChannelMember,
        entity: entity
      )
    end)
  end

  # TODO: Index channel property and use the index instead of find
  @doc "Remove all entities from this `channel`"
  @spec clear(channel) :: :ok
  def clear(channel) do
    Database.run(fn ->
      Database.find(
        Universa.Database.ChannelMember,
        channel: channel
      )
      |> Enum.each(fn channelmember ->
        Database.delete(channelmember)
      end)
    end)

    :ok
  end
end
