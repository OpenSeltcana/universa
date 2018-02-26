defmodule Universa.Component.LoggingIn do
  use Universa.Component

  default_value %{
    username: "",
    authentication_step: 0
  }
end
