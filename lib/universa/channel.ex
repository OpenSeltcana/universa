defmodule Universa.Channel do
  # Systems

  def add_system(channel, module) do
    GenServer.cast(module, {:subscribe_to_channel, channel})
  end

  def local_add_system(channel, capabilities) do
    Registry.register(Universa.ChannelRegistry,
                      "#{channel}_s",
                      capabilities)
  end

  def send(channel, message) do
    tasks = Enum.map(members_systems(channel), fn {pid, requirements} ->
      Task.async(fn -> Universa.System.handle(pid, message) end)
    end)
    # TODO: Add result checking back in
    #Enum.any?(tasks, fn(task) ->
    #  Task.await(task)
    #end)
    false
  end

  defp members_systems(channel) do
    Registry.lookup(Universa.ChannelRegistry, "#{channel}_s")
  end

  def rem_system(channel, type) do
    Registry.unregister_match(Universa.ChannelRegistry, "#{channel}_s", type)
  end

  # Entities

  def subscribe(channel, type) do
    Registry.register(Universa.ChannelRegistry, "#{channel}_e", type)
  end

  def members(channel) do
    Registry.lookup(Universa.ChannelRegistry, "#{channel}_e")
  end

  def get_types(channel, types) do
    members(channel)
    |> Enum.filter(fn {pid, type} -> Enum.member?(types, type) end)
    |> Enum.map(fn {pid, type} -> {type, pid} end)
    |> Map.new
  end

  def unsubscribe(channel) do
    Registry.unregister(Universa.ChannelRegistry, "#{channel}_e")
  end

  defmacro __using__(_options) do
    quote location: :keep do
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote location: :keep do
      # Global
      defp to_channel_identifier(ident), do: "#{@channel_name}:#{ident}"

      # System

      def add_system(which, module) do
        Universa.Channel.add_system(to_channel_identifier(which), module)
      end

      def send(which, message) do
        Universa.Channel.send(to_channel_identifier(which), message)
      end

      def rem_system(which, module) do
        Universa.Channel.rem_system(to_channel_identifier(which), module)
      end

      # Entity

      def subscribe(which, module) do
        Universa.Channel.subscribe(to_channel_identifier(which), module)
      end

      def members(which) do
        Universa.Channel.members(to_channel_identifier(which))
      end

      def get_types(which, types) do
        Universa.Channel.get_types(to_channel_identifier(which), types)
      end

      def unsubscribe(which, module) do
        Universa.Channel.subscribe(to_channel_identifier(which), module)
      end
    end
  end

  defmacro name(value) do
    quote do
      @channel_name unquote(value)
    end
  end
end
