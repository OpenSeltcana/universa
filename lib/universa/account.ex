defmodule Universa.Account do
  use Ecto.Schema

  alias Universa.Repo
  alias Universa.Account

  schema "accounts" do
    field :username, :string
    field :password, :string
    field :entity, :string
  end

  # Create a new table row, internal only
  def create(username, password, uuid) do 
    hash = Argon2.hash_pwd_salt(password)
    %Account{username: username, password: hash, entity: uuid}
    |> Repo.insert
  end

  # Return the channel row, but avoid creating new rows
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

  def destroy(username) do
    case Repo.get_by(Account, username: username) do
      nil ->
        :error
      account ->
        account
        |> Repo.delete
    end
  end
end