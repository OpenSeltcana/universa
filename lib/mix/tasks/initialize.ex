defmodule Mix.Tasks.Initialize do
  @moduledoc """
  Sets up the database storage and creates all neccesary tables.
  """

  use Mix.Task

  @impl true
  def run(_) do
    IO.puts("Creating local mnesia database storage.")
    :ok = :mnesia.create_schema([node()])
    IO.puts("... Done")
    IO.puts("Starting mnesia.")
    :ok = :mnesia.start()
    IO.puts("... Done")

    tables = all_tables()
    existing_tables = :mnesia.system_info(:local_tables)

    tables
    |> Enum.each(fn module ->
      case Enum.any?(existing_tables, fn existing_table ->
             existing_table == module
           end) do
        true ->
          IO.puts("Skipping \"#{Atom.to_string(module)}\" because it already exists...")

        false ->
          IO.puts("Creating table \"#{Atom.to_string(module)}\"")
          module.create()
          IO.puts("... Done")
      end
    end)

    IO.puts("Storing changes on disk.")
    {:atomic, :ok} = :mnesia.dump_tables(tables)
    IO.puts("... Done")
    IO.puts("Stopping mnesia.")
    :stopped = :mnesia.stop()
    IO.puts("... Done")
    IO.puts("Database is ready to run!")
  end

  defp all_tables do
    Mix.Task.run("loadpaths", [])
    # Fetch all .beam files
    Path.wildcard(Path.join([Mix.Project.build_path(), "**/ebin/**/*.beam"]))
    # Parse the BEAM for behaviour implementations
    |> Stream.map(fn path ->
      {:ok, {mod, chunks}} = :beam_lib.chunks('#{path}', [:attributes])
      {mod, get_in(chunks, [:attributes, :behaviour])}
    end)
    # Filter out behaviours we don't care about and duplicates
    |> Stream.filter(fn {_mod, behaviours} ->
      is_list(behaviours) && Universa.Database.Table in behaviours
    end)
    |> Enum.uniq()
    |> Enum.map(fn {module, _} -> module end)
  end
end
