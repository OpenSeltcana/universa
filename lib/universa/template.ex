defmodule Universa.Template do
  require EEx

  # TODO: Allow updating without recompiling module
  for path <- Path.wildcard("templates/**/*.eex") do
    fun = Path.basename(Path.rootname(path))
    EEx.function_from_file(:def, String.to_atom(fun), path, [:data, :fg, :bg])
  end
end
