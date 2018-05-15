defmodule Universa.Repo.Migrations.AddLocations do
  use Ecto.Migration

  def change do
    create table("locations") do
      add :location, :string
      add :uuid, :uuid
    end
  end
end
