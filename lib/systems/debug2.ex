defmodule System.Debug2 do
  use Universa.System

  event 00, :test, data do
    IO.inspect data
    :ok
  end
end