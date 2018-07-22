defmodule Universa.Account do
  alias Universa.Database

  def create(username, password, entity) do
    account = %Database.Account{
      username: username,
      password: password, # TODO: Um.. Hash it?
      entity: entity
    }

    Database.run(fn ->
      Database.write(account)
    end)

    :ok
  end

  def login(username, password) do
    case Database.run(fn ->
          Database.read(Database.Account, username: username)
        end) do
      nil -> {:error, :username}
      account -> 
        case account.password == password do
          true -> {:ok, account.entity}
          _ -> {:error, :password}
        end
    end
  end
end