defmodule Condo.Migration do
  @moduledoc "Functions for managing migrations with Condo."

  @migration_namespace Application.get_env(:condo, :migration_namespace, "")

  alias Ecto.Migration.{Runner, SchemaMigration}

  @doc """
  Runs the migrations for a `repo`. To specify the tenant, pass its schema name
  as a `prefix` option in the `opts`.
  """
  def run(repo, opts) do
    SchemaMigration.ensure_schema_migrations_table!(repo, opts[:prefix])

    repo
    |> collect_migrations(opts[:prefix])
    |> Enum.map(&migrate_up(repo, &1, opts))
  end

  defp collect_migrations(repo, prefix) do
    namespace = Regex.escape(@migration_namespace)
    migrated_versions = SchemaMigration.migrated_versions(repo, prefix)

    :code.all_loaded
    |> Enum.map(&elem(&1, 0))
    |> Enum.filter(&Regex.match?(~r/#{namespace}/, to_string(&1)))
    |> Enum.filter(&!Enum.member?(migrated_versions, &1.version))
    |> Enum.sort(&(&1.version <= &2.version))
  end

  defp migrate_up(repo, module, opts) do
    with {:ok, version} <- run_up(repo, module, opts),
         :ok <- schema_migration(repo, module, opts),
         do: {:ok, version}
  end

  defp run_up(repo, module, opts) do
    if Keyword.has_key?(module.__info__(:functions), :up) do
      {Runner.run(repo, module, :forward, :up, :up, opts), module.version}
    else
      {Runner.run(repo, module, :forward, :change, :up, opts), module.version}
    end
  end

  defp schema_migration(repo, module, opts) do
    SchemaMigration.up(repo, module.version, opts[:prefix])
    :ok
  end
end
