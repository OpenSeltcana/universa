defmodule System.Debug2 do
  use Universa.System

  parse :test, data do
    IO.inspect data
    :ok
  end
end