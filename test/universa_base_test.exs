defmodule UniversaBaseTest do
  use ExUnit.Case
  doctest UniversaBase

  test "greets the world" do
    assert UniversaBase.hello() == :world
  end
end
