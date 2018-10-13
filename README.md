# Condo

Condo is a multi-tenant adapter for Ecto. You can use this to create new
schemata in PostgreSQL. It's main advantages are:

- Compile-time migrations
- Prioritize `Ecto.Repo` functions for modifying and reading data

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `condo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:condo, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/condo](https://hexdocs.pm/condo).

## To Do

- README documentation
- Mix task to generate new migrations
- Mix task to run a migration
- Mix task and function to rollback a migration
- `Schema` module to cache migration SQL for creating and running new migrations
- Ensure migrations can be run async
- Setup tests
