defmodule Universa.Database do
  @moduledoc """
  Allows for interaction with the database, both reading and writing.

  # Creating database tables

  See `Universa.Database.Table`

  After which you can start making changes using this modue, for example:
  ```
  iex> alias Universa.Database
  Universa.Database

  iex> Database.run(fn -> 
    Database.write(%Database.NewObject{id: 20})
    Database.write(%Database.NewObject{id: 20, count: 2, test: :ok})
  end)
  :ok
  ```
  """

  @doc """
  Retrieves the full version of `object` with matching primarykey (other properties are ignored) out of the database 
    
  If `object` is found in database, will return its entirety, else will return empty.

  ## Examples

      iex> alias Universa.Database
      Universa.Database
      iex> Database.run(fn -> Database.read(%Database.Entity{uuid: "test"}) end)
      [{Database.Entity, "test", []}]
      iex> Database.run(fn -> Database.read(%Database.Entity{uuid: "not_test"}) end)
      []
  """
  @spec read(atom, list) :: map() | nil
  def read(type, properties) do
    case :mnesia.read(type.read_tuple(properties)) do
      [tuple] -> type.output_tuple(Tuple.to_list(tuple))
      [] -> nil
    end
  end

  @doc """
  Adds `object` to the database
    
  Will always return `:ok` regardless of wether an object existed with the same
  primary key or not. If another object has the same primary key, it will get
  overwritten.

  ## Examples

      iex> alias Universa.Database
      Universa.Database
      
      iex> Database.run(fn -> Database.write(%Database.Entity{uuid: "test"}) end)
      :ok
      
      iex> Database.run(fn -> Database.write(%Database.Entity{uuid: "test"}) end)
      :ok
      
  """
  @spec write(map()) :: :ok
  def write(object) do
    :mnesia.write(object.__struct__.write_tuple(object))
  end

  @doc """
  Finds objects of module `type` with matching `properties`.
    
  Always returns a list with all matching objects.

  ## Examples

      iex> alias Universa.Database
      Universa.Database
      
      iex> Database.run(fn -> Database.find(Database.Entity, [uuid: "test"]) end)
      [%Universa.Database.Entity{systems: [], uuid: "test"}]
      
      iex> Database.run(fn -> Database.find(Database.Entity, [uuid: "not_test"]) end)
      []
      
  """
  @spec find(atom, list) :: list
  # find(Universa.Database.Entity, [systems: []])
  def find(type, properties) do
    Enum.map(:mnesia.match_object(type.find_tuple(properties)), fn tuple ->
      type.output_tuple(Tuple.to_list(tuple))
    end)
  end

  @doc """
  Removes `object` with matching primarykey (other properties are ignored) out of the database
    
  Will always return `:ok` regardless of wether a key was removed or not.

  ## Examples

      iex> alias Universa.Database
      Universa.Database
      
      iex> Database.run(fn -> Database.delete(%Database.Entity{uuid: "test"}) end)
      :ok
      
      iex> Database.run(fn -> Database.delete(%Database.Entity{uuid: "test"}) end)
      :ok
      
  """
  @spec delete(map()) :: :ok
  def delete(object) do
    :mnesia.delete(object.__struct__.delete_tuple(object))
  end

  @doc """
  Runs the `func` inside a `:mnesia.transaction/2`.

  Runs the entire code in one go, it ensures either all changes are made or none
  of them are made. Also allows multiple processes to change the same record
  without interfereing with another and prevents deadlocks by retrying only three
  times.

  ## Examples

      iex> Database.run(fn ->
        Enum.each(Database.find(Database.Entity, []), fn(ent) ->
            Database.delete(ent)
        end)
      end)
      :ok
      
  """
  @spec run((() -> any())) :: any()
  def run(func) when is_function(func, 0) do
    {:atomic, result} = :mnesia.transaction(func, [], 3)
    result
  end

  @doc """
  Stores all active tables on the disk, so if the server is restarted will use
  those values instead of empty.

  WARNING: also saves databases not part of `Universa`.
  """
  @spec save() :: :ok
  def save() do
    {:atomic, :ok} =
      :mnesia.system_info(:local_tables)
      |> Enum.reject(fn x -> x == :schema end)
      |> :mnesia.dump_tables()

    :ok
  end
end
