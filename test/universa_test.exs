defmodule UniversaTest do
  use ExUnit.Case

  alias Universa.Repo
  alias Universa.Entity
  alias Universa.Component

  import Ecto.Query

  test "the database works as it should" do
    # assert we can insert and query an entity
    {:ok, owner} = Entity.create
    assert [owner.uuid] == Entity |> select([owner], owner.uuid) |> Repo.all

    # assert we can insert component
    Component.create(owner, "list", %{value: "value1"})
    assert {:ok, %{"value" => "value1"}} == Map.fetch(Entity.component(owner, "list"), :value)

    list = Entity.component(owner, "list")
    {:ok, _} = Component.update(list, %{value: "value2"})
    assert {:ok, %{"value" => "value2"}} == Map.fetch(Entity.component(owner, "list"), :value)

    {:ok, _} = Entity.destroy(owner)
  end
end
