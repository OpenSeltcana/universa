defmodule Universa.Component do
  alias Universa.Database
  alias Universa.Event

  @callback create(String.t, map()) :: any()

  defmacro __using__(_options) do
    quote location: :keep do
      @properties []

      @behaviour unquote(__MODULE__)

      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote location: :keep do
      @properties Map.new(@properties)
      @keys Map.keys(@properties)

      def create(%Universa.Entity{} = entity, properties),
        do: create(entity.uuid, properties)
        

      def create(entity, properties) do
        database_component = %Database.Component{
          uuid: UUID.uuid4(),
          entity: entity,
          type: __MODULE__,
          values: Map.merge(@properties, Map.take(properties, @keys))
        }

        Database.run(fn ->
          Database.write(database_component)
        end)

        component = database_to_local(database_component)

        :ok =
          %Event{
            type: __MODULE__,
            data: %{action: :component_created, new: component}
          }
          |> Event.emit()

        component
      end

      def take(%Universa.Entity{} = entity), do: take(entity.uuid)

      def take(entity) do
        case Database.run(fn ->
          Database.find(Database.Component, type: __MODULE__, entity: entity)
        end) do
          [result] -> database_to_local(result)
          _ -> nil
        end
      end

      def store(%{component_type: __MODULE__} = component) do
        database_component = local_to_database(component)

        :ok =
          %Event{
            type: __MODULE__,
            data: %{action: :component_changed, old: take(database_component.uuid), new: component}
          }
          |> Event.emit()

        Database.run(fn ->
          Database.write(database_component)
        end)
      end

      def update(%{component_type: __MODULE__} = old_component, key, value) do
        new_component = Map.update!(old_component, key, fn _ -> value end)

        database_component = local_to_database(new_component)

        :ok =
          %Event{
            type: __MODULE__,
            data: %{action: :component_changed, old: old_component, new: new_component}
          }
          |> Event.emit()

        Database.run(fn ->
          Database.write(database_component)
        end)
      end

      def delete(%{component_type: __MODULE__} = component) do
        database_component = local_to_database(component)

        :ok =
          %Event{
            type: __MODULE__,
            data: %{action: :component_delete, old: component}
          }
          |> Event.emit()

        Database.run(fn ->
          Database.delete(database_component)
        end)
      end

      def systems() do
        Universa.System.list(__MODULE__)
      end

      def list() do
        Database.run(fn ->
          Database.find(Database.Component, [type: __MODULE__])
        end)
      end

      def defaults(), do: @properties

      defp local_to_database(%{} = component) do
        %Database.Component{
          uuid: component.component_rowid,
          entity: component.component_entity,
          type: component.component_type,
          values: Map.drop(component, [
            :component_rowid,
            :component_entity,
            :component_type
          ])
        }
      end

      defp database_to_local(%Database.Component{} = component) do
        Map.merge(%{
          component_rowid: component.uuid,
          component_entity: component.entity,
          component_type: __MODULE__,
        }, component.values)
      end
    end
  end

  defmacro property(properties) do
    quote location: :keep do
      @properties @properties ++ unquote(properties)
    end
  end

  def create(entity, type, properties), do: type.create(entity, properties)

  def take(entity, type), do: type.take(entity)

  def store(component), do: component.component_type.store(component)

  def delete(component), do: component.component_type.delete(component)

  def list() do
    Database.run(fn ->
      Database.find(Database.Component, [])
    end)
  end

  def list(type) do
    type.list()
  end
end
