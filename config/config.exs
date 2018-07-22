# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :universa,
  # The port the TCP server listens to
  port: 4000,
  # Filters that are assigned to new connections
  filters: [Universa.Filter.MCCP, Universa.Filter.Telnet, Universa.Filter.Ascii],
  # The shell that is assigned to new connections
  shell: Universa.Shell.Login,
  # The parsers that are given to newly created accounts
  parsers: [
    [50, Universa.Parser.Help],
    [50, Universa.Parser.Say],
    [50, Universa.Parser.OOC],
    [50, Universa.Parser.Look]
  ],
  # The name all new characters get
  default_name: "New Person"
