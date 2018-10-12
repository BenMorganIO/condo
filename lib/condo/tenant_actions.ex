defmodule Condo.TenantActions do
  @schema_prefix Application.get_env(:condo, :schema_prefix, "tenant_")

  alias Condo.Migration

  def prefix(queryable, tenant) do
    queryable
    |> Ecto.Queryable.to_query
    |> Map.put(:prefix, schema_prefix(tenant))
  end

  def schema_prefix(tenant) when is_integer(tenant), do: "#{@schema_prefix}#{tenant}"
  def schema_prefix(tenant) when is_binary(tenant), do: "#{@schema_prefix}#{tenant}"
  def schema_prefix(tenant) do
    cond do
      is_binary(tenant.id) -> schema_prefix(tenant.id)
      is_integer(tenant.id) -> schema_prefix(tenant.id)
    end
  end

  def new_tenant(repo, tenant) do
    with {:ok, _} <- create_schema(repo, tenant),
         do: migrate_tenant(repo, tenant)
  end

  def drop_tenant(repo, tenant) do
    repo.query("DROP SCHEMA \"#{schema_prefix(tenant)}\" CASCADE", [])
  end

  def create_schema(repo, tenant) do
    repo.query("CREATE SCHEMA \"#{schema_prefix(tenant)}\"", [])
  end

  def migrate_tenant(repo, tenant) do
    run_migration(repo, prefix: schema_prefix(tenant))
  end

  defp run_migration(repo, opts) do
    opts =
      if opts[:to] || opts[:step] || opts[:all],
        do: opts,
        else: Keyword.put(opts, :all, true)

    Migration.run(repo, opts)
  end
end
