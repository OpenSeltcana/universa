defmodule Universa.SystemSupervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    # Get a list of all Systems available at launch and start them.
    Supervisor.init(available_systems(), strategy: :one_for_one)
  end

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
