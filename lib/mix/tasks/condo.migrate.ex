defmodule Mix.Tasks.Condo.Migrate do
  use Mix.Task

  import Mix.Ecto

  @shortdoc "Runs the migrations for the tenants."

  def run(args) do
    no_umbrella!("condo.migrate")
    repos = Mix.Ecto.parse_repo(args)

    Enum.each(repos, fn repo ->
      Ecto.Migrator.with_repo(repo, fn repo ->
        stream = repo.stream(repo.tenant_ids)

        repo.transaction(fn ->
          Enum.each(stream, &Condo.migrate_tenant(repo, &1))
        end)
      end)
    end)
  end
end
