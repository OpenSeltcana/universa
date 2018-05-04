defmodule System.Debug do
  use Universa.System

  parse :test2, data, do: parse(:test, data)

  parse :test, data do
    IO.inspect data
    :ok
  end
end