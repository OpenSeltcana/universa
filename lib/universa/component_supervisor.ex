defmodule Universa.ComponentSupervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def new(type) do
    child_spec = {type, []}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def new(type, entity_uuid) do
    child_spec = {type, [entity_uuid]}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def rem(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  def children do
    DynamicSupervisor.which_children(__MODULE__)
  end

  def count_children do
    DynamicSupervisor.count_children(__MODULE__)
  end
end
