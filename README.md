# Universa

WIP ecto branch, instead of having GenServers for entities, use the database directly.

__Benefits:__

- No loss of data when server crashes

__Cons:__

- More overhead
- Slower?

## Setup

To set up the database, first get all dependencies, then create the database and then migrate the schema to the database, finally test if the database can be saved to and read from.

```shell
$ mix deps.get
$ mix ecto.create
$ mix ecto.migrate
$ mix test
```

# Usage

Simple usage of creating an entity, and then create a new component attached to it.

```Elixir
$ iex -S mix
Erlang/OTP 20 [erts-9.3] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:10] [hipe] [kernel-poll:false]

Interactive Elixir (1.6.4) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> {:ok, ent} = Universa.Entity.create

13:02:28.615 [debug] QUERY OK db=0.4ms queue=0.1ms
begin []
 
13:02:28.693 [debug] QUERY OK db=49.2ms
INSERT INTO "entities" ("uuid","inserted_at","updated_at") VALUES (?1,?2,?3) ;--RETURNING ON INSERT "entities","id" ["8fda8c65-bafa-4511-bfcb-2a3fd77142b3", {{2018, 5, 3}, {11, 2, 28, 629144}}, {{2018, 5, 3}, {11, 2, 28, 638548}}]
 
13:02:28.724 [debug] QUERY OK db=30.5ms
commit []
{:ok,
 %Universa.Entity{
   __meta__: #Ecto.Schema.Metadata<:loaded, "entities">,
   components: #Ecto.Association.NotLoaded<association :components is not loaded>,
   id: 1,
   inserted_at: ~N[2018-05-03 11:02:28.629144],
   updated_at: ~N[2018-05-03 11:02:28.638548],
   uuid: "8fda8c65-bafa-4511-bfcb-2a3fd77142b3"
 }}
iex(2)> {:ok, name} = Universa.Component.create(ent, "name", %{value: "Test Entity"})

16:39:09.510 [debug] QUERY OK source="entities" db=2.2ms decode=0.1ms queue=0.1ms
SELECT e0."id", e0."uuid", e0."inserted_at", e0."updated_at" FROM "entities" AS e0 WHERE (e0."uuid" = ?1) ["8fda8c65-bafa-4511-bfcb-2a3fd77142b3"]
 
16:39:09.512 [debug] QUERY OK db=0.7ms queue=0.3ms
begin []
 
16:39:09.535 [debug] QUERY OK db=8.0ms
INSERT INTO "components" ("entity_id","key","value") VALUES (?1,?2,?3) ;--RETURNING ON INSERT "components","id" [1, "name", %{value: "Test Entity"}]
 
16:39:09.546 [debug] QUERY OK db=10.6ms
commit []
{:ok,
 %Universa.Component{
   __meta__: #Ecto.Schema.Metadata<:loaded, "components">,
   entity: #Ecto.Association.NotLoaded<association :entity is not loaded>,
   entity_id: 1,
   id: 1,
   key: "name",
   value: %{value: "Test Entity"}
 }}
iex(3)> 
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/universa](https://hexdocs.pm/universa).

