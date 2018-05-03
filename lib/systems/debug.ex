defmodule System.Debug do
  use Universa.System

  def events, do: [:test, :test2]

  def parse(:test, data) do
    IO.inspect data
  end
end