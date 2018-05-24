defmodule Universa.Account do
  use Ecto.Schema

  alias Universa.Repo
  alias Universa.Account

  schema "accounts" do
    field(:username, :string)
    field(:password, :string)
    field(:entity, :string)
  end

  # Create a new table row, internal only
  @spec create(String.t(), String.t(), String.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create(username, password, uuid) do
    hash = Argon2.hash_pwd_salt(password)

    {:ok, row} =
      %Account{username: username, password: hash, entity: uuid}
      |> Repo.insert()

    {:ok, row}
  end

  # Return the channel row, but avoid creating new rows
  @spec login(String.t(), String.t()) :: {:ok, String.t()} | {:error, :username | :password}
  def login(username, password) do
    case Repo.get_by(Account, username: username) do
      nil ->
        Argon2.no_user_verify()
        {:error, :username}

      user ->
        case Argon2.verify_pass(password, user.password) do
          true -> {:ok, user.entity}
          false -> {:error, :password}
        end
    end
  end

  @spec destroy(String.t()) :: {:ok, Ecto.Schema.t()} | {:error, any}
  def destroy(username) do
    case Repo.get_by(Account, username: username) do
      nil ->
        {:error, :not_found}

      account ->
        account
        |> Repo.delete()
    end
  end
end
