defmodule Universa.System do
  @callback handle(event :: any, channel :: any) :: boolean()

  defmacro __using__(_options) do
    quote location: :keep do
      @behaviour Universa.System
      @auto_subscribe false

      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote location: :keep do
      def auto_subscribe do
        @auto_subscribe
      end

      def handle(_,_), do: false
    end
  end

  defmacro auto_subscribe do
    quote location: :keep do
      @auto_subscribe true
    end
  end

  def auto_subscribe_systems do
    for module <- available_systems() do
      if module.auto_subscribe do
        Universa.Channel.Server.add_system(module)
      end
    end
  end

  # Thank you exrm!
  # https://stackoverflow.com/questions/36433481/find-all-modules-that-adopted-behavior
  defp available_systems do
    # Ensure the current projects code path is loaded
    Mix.Task.run("loadpaths", [])
    # Fetch all .beam files
    Path.wildcard(Path.join([Mix.Project.build_path, "**/ebin/**/*.beam"]))
    # Parse the BEAM for behaviour implementations
    |> Stream.map(fn path ->
      {:ok, {mod, chunks}} = :beam_lib.chunks('#{path}', [:attributes])
      {mod, get_in(chunks, [:attributes, :behaviour])}
    end)
    # Filter out behaviours we don't care about and duplicates
    |> Stream.filter(fn {_mod, behaviours} -> is_list(behaviours) && Universa.System in behaviours end)
    |> Enum.uniq
    |> Enum.map(fn {module, _} -> module end)
  end
end
