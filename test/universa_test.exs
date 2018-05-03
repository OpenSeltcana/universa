defmodule UniversaTest do
  use ExUnit.Case

  alias Universa.Repo
  alias Universa.Entity
  alias Universa.Component

  import Ecto.Query

  setup_all do
    {:ok, pid} = Universa.start(nil, nil)
    {:ok, [pid: pid]}
  end

  setup do
    on_exit fn ->
      Repo.delete_all(Entity)
      Repo.delete_all(Component)
    end
  end

  test "the database works as it should" do
    # assert we can insert and query an entity
    {:ok, owner} = Universa.Entity.create
    assert [owner.uuid] == Entity |> select([owner], owner.uuid) |> Repo.all

    # assert we can insert component
    Universa.Component.create(owner, "list", %{value: "value1"})
    assert {:ok, %{"value" => "value1"}} == Map.fetch(Universa.Entity.component(owner, "list"), :value)

    list = Universa.Entity.component(owner, "list")
    {:ok, _} = Universa.Component.update(list, %{value: "value2"})
    assert {:ok, %{"value" => "value2"}} == Map.fetch(Universa.Entity.component(owner, "list"), :value)

    {:ok, _} = Universa.Entity.destroy(owner)
  end
end
