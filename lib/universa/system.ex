defmodule Universa.System do
  @callback handle(event :: any) :: boolean()

  defmacro __using__(_options) do
    quote location: :keep do
      @behaviour Universa.System
      @auto_subscribe false
      @capabilities []

      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote location: :keep do
      use GenServer

      def start_link(_) do
        GenServer.start_link(__MODULE__, nil, name: __MODULE__)
      end

      def init(_) do
        if @auto_subscribe, do:
          Universa.Channel.local_add_system("server", @capabilities)

        {:ok, nil}
      end

      def handle_call(event, _, _) do
        reply = __MODULE__.handle(event)

        {:reply, reply != :no_work, nil}
      end

      def handle(_) do
        # Throw away cast if turns out we cant handle this cast
        :no_work
      end

      def handle_cast({:subscribe_to_channel, channel}, _) do
        Universa.Channel.local_add_system(channel, @capabilities)
        {:noreply, nil}
      end

      def handle_info(msg, state) do
        # TODO: Is it okay to ignore info messages?
        {:noreply, [], state}
      end
    end
  end

  # Macro for automatically adding the System to the server Channel
  defmacro auto_subscribe do
    quote location: :keep do
      @auto_subscribe true
    end
  end

  # Macro for announcing the type of messages we can handle
  defmacro capability(type) do
    quote location: :keep do
      @capabilities [{unquote(type), []} | @capabilities]
    end
  end

  # As above but with a list of required modules
  defmacro capability(type, requires) do
    quote location: :keep do
      @capabilities [{unquote(type), unquote(requires)} | @capabilities]
    end
  end

  # Function for passing events to the System
  def handle(pid, event) do
    GenServer.call(pid, event)
  end
end
