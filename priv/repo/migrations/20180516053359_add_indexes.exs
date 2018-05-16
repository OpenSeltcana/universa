defmodule Universa.Repo.Migrations.AddIndexes do
  use Ecto.Migration

  def change do
    create unique_index(:entities, [:uuid])
    create unique_index(:components, [:entity_id, :key])
    create unique_index(:channels, [:name])
    create unique_index(:locations, [:location])
  end
end
