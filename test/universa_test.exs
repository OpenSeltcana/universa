defmodule UniversaTest do
  use ExUnit.Case
  doctest Universa

  test "greets the world" do
    assert Universa.hello() == :world
  end
end
