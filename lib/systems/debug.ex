defmodule System.Debug do
  use Universa.System

  event 99, :test2, data, do: event(00, :test, data)

  event 00, :test, data do
    IO.inspect data
    :ok
  end
end