defmodule Universa.Repo.Migrations.AddChannels do
  use Ecto.Migration

  def change do
    create table("channels") do
      add :name, :string
      # was add :entities, {:array, :uuid}, but SQLite doesn't support arrays
      add :entities, :string, default: ""
    end
  end
end
