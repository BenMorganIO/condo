defmodule Condo do
  @moduledoc "Main functions for Condo."

  @prefix Application.get_env(:condo, :prefix, "tenant_")

  @type query ::
          {:ok,
           %{
             :rows => nil | [[term()] | binary()],
             :num_rows => non_neg_integer(),
             optional(atom()) => any()
           }}
          | {:error, Exception.t()}
  @type queryable :: Ecto.Queryable.t()
  @type tenant_id :: String.t() | integer() | atom()
  @type tenant :: tenant_id | %{id: tenant_id}

  alias Condo.Migration

  @doc """
  Set a prefix for a query or for a tenant. If one arity is provided, we assume
  that the prefix is for an ID or for a struct.

  ## Examples

      iex> Condo.prefix("public")
      "public"

      iex> Condo.prefix(:public)
      "public"

      iex> Condo.prefix(123)
      "tenant_123"

      iex> Condo.prefix("abc")
      "tenant_abc"

      iex> Condo.prefix(%{id: 123})
      "tenant_123"

  """

  @spec prefix(tenant) :: String.t()
  def prefix("public"), do: "public"
  def prefix(:public), do: "public"
  def prefix(tenant) when is_integer(tenant), do: "#{@prefix}#{tenant}"
  def prefix(tenant) when is_binary(tenant), do: "#{@prefix}#{tenant}"
  def prefix(tenant), do: prefix(tenant.id)

  @spec prefix(queryable, tenant) :: queryable
  def prefix(queryable, tenant) do
    queryable
    |> Ecto.Queryable.to_query()
    |> Map.put(:prefix, prefix(tenant))
  end

  @doc """
  Creates a new tenant. It will first start by creating the schema, then it will
  ensure that there is a schema_migrations table. Once that has happened, each
  migration in your migration namespace will run and also write to the
  schema_migrations table that it has ran.
  """
  @spec new_tenant(queryable, tenant) :: {:ok, String.t(), list({:ok, non_neg_integer()})}
  def new_tenant(repo, tenant) do
    with {:ok, _} <- create_schema(repo, tenant) do
      {:ok, prefix(tenant), migrate_tenant(repo, tenant)}
    end
  end

  @doc "Drops a schema."
  @spec drop_tenant(queryable, tenant) :: query
  def drop_tenant(repo, tenant) do
    repo.query("DROP SCHEMA \"#{prefix(tenant)}\" CASCADE", [])
  end

  @doc "Creates a schema."
  @spec create_schema(queryable, tenant) :: query
  def create_schema(repo, tenant) do
    repo.query("CREATE SCHEMA \"#{prefix(tenant)}\"", [])
  end

  @doc """
  Upwards migration. First checks for a `change/0` function and then checks for
  an `up/0` function.
  """
  @spec migrate_tenant(queryable, tenant) :: list({:ok, non_neg_integer()})
  def migrate_tenant(repo, tenant) do
    run_migration(repo, :up, prefix: prefix(tenant))
  end

  @doc """
  Rollsback the latest migration. First checks for a `change/0` function and
  then checks for a `down/0` function.
  """
  @spec rollback_tenant(queryable, tenant) :: {:ok, non_neg_integer()}
  def rollback_tenant(repo, tenant) do
    run_migration(repo, :down, prefix: prefix(tenant))
  end

  defp run_migration(repo, direction, opts) do
    opts =
      if opts[:to] || opts[:step] || opts[:all],
        do: opts,
        else: Keyword.put(opts, :all, true)

    Migration.run(repo, direction, opts)
  end
end
