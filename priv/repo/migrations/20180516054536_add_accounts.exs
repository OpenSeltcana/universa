defmodule Universa.Repo.Migrations.AddAccounts do
  use Ecto.Migration

  def change do
    create table("accounts") do
      add :username, :string
      add :password, :string
      add :entity, :uuid
    end

    create unique_index(:accounts, [:username])
  end
end
