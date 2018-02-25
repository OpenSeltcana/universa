defmodule Universa.ComponentSupervisor do
  use DynamicSupervisor

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add_component(type) do
    child_spec = {type, []}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def rem_component(uuid) do
    DynamicSupervisor.terminate_child(__MODULE__, "entity:#{uuid}")
  end

  def children do
    DynamicSupervisor.which_children(__MODULE__)
  end

  def count_children do
    DynamicSupervisor.count_children(__MODULE__)
  end
end
