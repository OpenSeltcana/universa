defmodule Universa.System.Debug do
  alias Universa.System

  use System

  event 0, :component, data do
    IO.inspect data
    :ok
  end

  event 0, :entity, data do
    IO.inspect data
    :ok
  end

  event 0, :terminal, data do
    IO.inspect data
    :ok
  end

  event 0, :telnet, data do
    IO.inspect data
    :ok
  end
end