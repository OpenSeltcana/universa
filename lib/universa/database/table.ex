defmodule Universa.Database.Table do
  @moduledoc """
  Helper for creating tables in the database.

  ## Creating a new table

  To create a new database table simply create a file with these contents:

  ```
  defmodule Universa.Database.NewObject do
    use Universa.Database.Table
    
    deftable id: 0, count: 0, test: :nil
  end
  ```

  Be careful and know that the first property for `deftable/1` is always the
  primary key and thus needs to be unique. All values given are used as default
  values.
  """

  @callback create() :: any()

  defmacro __using__(_options) do
    quote location: :keep do
      @tabledefaults []
      @tablekeys []
      @primarykey :error

      @behaviour unquote(__MODULE__)

      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)

      @moduledoc """
      Automatically generated database table.

      This is an automatically generated file, sadly we can't provide detailed 
      documentation for this module at this time. This file was generated so the
      code knows how to create and use the associated table, using 
      "#{__MODULE__}" as the name of the table.

      Please see `Universa.Database.Table` for more information.
      """
    end
  end

  defmacro __before_compile__(_env) do
    quote location: :keep do
      @doc false
      def create() do
        :mnesia.create_table(__MODULE__, attributes: @tablekeys, ram_copies: [node()])
      end

      @doc false
      def read_tuple(data) when is_list(data), do: {__MODULE__, Keyword.get(data, @primarykey)}

      @doc false
      def write_tuple(%__MODULE__{} = data) do
        # This is to enforce order of keys
        result = Enum.map(@tablekeys, fn key -> Map.get(data, key) end)
        List.to_tuple([__MODULE__ | result])
      end

      @doc false
      def find_tuple(searchparams) do
        result = Enum.map(@tablekeys, fn key -> Keyword.get(searchparams, key, :_) end)
        List.to_tuple([__MODULE__ | result])
      end

      @doc false
      def delete_tuple(%__MODULE__{} = data), do: read_tuple(Map.to_list(data))

      @doc false
      def output_tuple([_module | list]) do
        struct(__MODULE__, Enum.zip(@tablekeys, list))
      end

      @doc """
      Returns the primary key for this table, this key must be unique for every entry.

      ## Example

      ```
      iex> Universa.Database.Entity.primary_key
      :uuid
      ```
      """
      @spec primary_key() :: atom
      def primary_key(), do: @primarykey

      @doc """
      Returns all keys for this table.

      ## Example

      ```
      iex> Universa.Database.Entity.keys
      [:uuid, :systems]
      ```
      """
      @spec keys() :: list
      def keys(), do: @tablekeys

      @doc """
      Returns a list with all keys and their defaults.

      ## Example

      ```
      iex> Universa.Database.Entity.defaults
      [uuid: "", systems: []]
      ```
      """
      @spec defaults() :: list
      def defaults(), do: @tabledefaults
    end
  end

  @doc """
  Set the keys for this table.
  """
  defmacro deftable(tablekeys) do
    quote location: :keep do
      defstruct unquote(tablekeys)
      @tabledefaults unquote(tablekeys)
      @tablekeys Keyword.keys(unquote(tablekeys))
      @primarykey hd(Keyword.keys(unquote(tablekeys)))
      @modulename unquote(__MODULE__)
    end
  end
end
