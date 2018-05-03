defmodule Universa.Repo.Migrations.CreateStart do
  use Ecto.Migration

  def change do
  	create table(:entities) do
	  	add :uuid, :uuid
	  	timestamps()
  	end

    create table(:components) do
      add :entity_id, references(:entities, on_delete: :delete_all)
      add :key, :string
      add :value, :map
    end
  end
end
