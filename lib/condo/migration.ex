defmodule Condo.Migration do
  @moduledoc "Functions for managing migrations with Condo."

  @migration_namespace Application.get_env(:condo, :migration_namespace, "")

  alias Ecto.Migrator
  alias Ecto.Migration.{Runner, SchemaMigration}

  def namespace, do: @migration_namespace

  @doc """
  Runs the migrations for a `repo`. To specify the tenant, pass its schema name
  as a `prefix` option in the `opts`.
  """
  def run(repo, :up, opts) do
    SchemaMigration.ensure_schema_migrations_table!(repo, opts[:prefix])

    repo
    |> pending_migrations(opts[:prefix])
    |> Enum.map(&migrate_up(repo, &1, opts))
  end

  def run(repo, :down, opts) do
    SchemaMigration.ensure_schema_migrations_table!(repo, opts[:prefix])

    module =
      repo
      |> migrated_migrations(opts[:prefix])
      |> List.last

    migrate_down(repo, module, opts)
  end

  defp pending_migrations(repo, prefix) do
    migrated_versions = Migrator.migrated_versions(repo, prefix: prefix)
    Enum.filter(collect_migrations(), &!Enum.member?(migrated_versions, &1.version))
  end

  defp migrated_migrations(repo, prefix) do
    migrated_versions = Migrator.migrated_versions(repo, prefix: prefix)
    Enum.filter(collect_migrations(), &Enum.member?(migrated_versions, &1.version))
  end

  defp collect_migrations do
    namespace = Regex.escape(@migration_namespace)

    :code.all_loaded
    |> Enum.map(&elem(&1, 0))
    |> Enum.filter(&Regex.match?(~r/#{namespace}/, to_string(&1)))
    |> Enum.sort(&(&1.version <= &2.version))
  end

  defp migrate_up(repo, module, opts) do
    with {:ok, version} <- runner(repo, module, :up, opts),
         :ok <- schema_migration(repo, module, opts),
         do: {:ok, version}
  end

  defp migrate_down(repo, module, opts) do
    with {:ok, version} <- runner(repo, module, :down, opts),
         :ok <- schema_rollback(repo, module, opts),
         do: {:ok, version}
  end

  defp runner(repo, module, direction, opts) do
    version = module.version

    if Keyword.has_key?(module.__info__(:functions), :up) do
      {Runner.run(repo, version, module, :forward, direction, direction, opts), version}
    else
      runner_direction = if direction == :up, do: :forward, else: :backward
      {Runner.run(repo, version, module, runner_direction, :change, direction, opts), version}
    end
  end

  defp schema_migration(repo, module, opts) do
    SchemaMigration.up(repo, module.version, opts[:prefix])
    :ok
  end

  defp schema_rollback(repo, module, opts) do
    SchemaMigration.down(repo, module.version, opts[:prefix])
    :ok
  end
end
