# Condo

[![CircleCI](https://circleci.com/gh/BenMorganIO/condo.svg?style=svg)](https://circleci.com/gh/BenMorganIO/condo)
[![codecov](https://codecov.io/gh/BenMorganIO/condo/branch/master/graph/badge.svg)](https://codecov.io/gh/BenMorganIO/condo)

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

## Setup with Mix Tasks

To set Condo up, you'll need to decide on two things.

1. What prefix would you like for your tenants?
2. Where would you like to store your migrations?

I recommend setting your migration prefix to a description of your data instead
of simply calling it `tenant_` as is the default. For some that's `store_`
(SaaS) and for others that's `region_` (sharding by and for geolocation.) You
can do this by:

```elixir
config :condo,
  prefix: "tenant_"
```

Next up is simply supplying a place where you would like your migrations written
to. Condo will figure out the path based on the module name supplied. If you're
managing tenants by `App.Company` then you would ideally want the migration
module namespace to be `App.Company.Migrations`. You can set this as so:

```elixir
config :condo,
  migration_namespace: "App.Company.Migrations"
```

And Condo will now store the migrations in the `lib/app/company/migrations`
folder. Magic!

### Generating a Migration

First up is the initial migration, you create one as so:

```elixir
mix condo.gen.migration create_products
```

This will create a template that should look as so:

```elixir
defmodule BlitzPG.LeagueMatches.Migrations.CreateProducts do
  use Ecto.Migration

  def version, do: 20191122003859

  def change do

  end
end
```

You'll notice that unlike Ecto's migration generator, Condo adds a `version()`
function. Since Condo's migrations are compile-time and not run-time, we don't
have access to reading the timestamp off of the file name. However, Condo does
prefix all of the file names with the timestamp since this does help
significantly with telling the order of the migrations and how they're run. The
same result is created with exposing the timestamp in the module as a function
instead of in the filename.

### Running and Rolling Back a Migration

As you would think, Condo's migration commands are not that different from
Ecto's and even accept similar argument for feature parity.

```elixir
mix condo.migrate
mix condo.migrate -r App.ObscureRepo

mix condo.rollback
mix condo.rollback -r App.ObscureRepo
```

## Condo's Syntactic Sugar

Condo doesn't just aim to give you easier migration handling with non-public
postgres schemas, but also to make sure your application code better manages it.

### Schema Prefix

Although it's quite simple to do it yourself you can get a schema prefix made
for you as so:

```elixir
# DIY
Repo.all(Product, prefix: "store_#{store.id}")

# Condo Method with a struct supplied
Repo.all(Product, prefix: Condo.prefix(store))

# Or pass in a binary, atom, or integer without the struct needed
Repo.all(Product, prefix: Condo.prefix(store.id))
Repo.all(Product, prefix: Condo.prefix(store.uuid))
Repo.all(Product, prefix: Condo.prefix(:north_america))

# Get back to the public schema just-in-case
Condo.prefix(:public)
# => "public"
```

## To Do

- `Schema` module to cache migration SQL for creating and running new migrations
- Setup tests
