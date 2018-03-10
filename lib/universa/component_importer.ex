defmodule Universa.ComponentImporter do
  require Logger

  def import(uuid, file_path) do
    base_path = Universa.get_config(Directories, :entity_path)
    full_path = Path.join(base_path, file_path)

    # YAML file can contain multiple documents, pick a random one if multiple exist
    versions = :yamerl_constr.file(full_path)
    components = Enum.random versions

    # Create each compononent the way the YAML file tells us to.
    Enum.each(components, fn {component_name, value} ->
      #try do
	capitalized = String.capitalize("#{component_name}")
	apply(String.to_existing_atom("Elixir.Universa.Component.#{capitalized}"), :new, [uuid, value])
      #rescue
      #  _ ->
	#  Logger.error "Error while loading '#{file_path}', when parsing '#{component_name}'"
      #end
    end)
  end
end
