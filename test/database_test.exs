defmodule Universa.Database.Test do
  use ExUnit.Case
  doctest Universa

  test "can create an entity" do
    assert :mnesia.transaction(fn ->
             Universa.Database.write(%Universa.Database.Entity{uuid: "test"})
           end)
  end

  test "can retrieve the test entity" do
    assert :mnesia.transaction(fn ->
             Universa.Database.read(%Universa.Database.Entity{uuid: "test"})
           end)
  end
end
