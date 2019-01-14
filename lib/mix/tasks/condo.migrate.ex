defmodule Mix.Tasks.Condo.Migrate do
  use Mix.Task

  import Mix.Ecto
  import Mix.EctoSQL

  @shortdoc "Runs the migrations for the tenants."

  def run(args) do
    no_umbrella!("condo.migrate")
    repos = parse_repo(args)

    Enum.each repos, fn repo ->
      ensure_repo(repo, args)
      ensure_started(repo, [])

      stream = repo.stream(repo.tenant_ids)
      repo.transaction fn ->
        Enum.each(stream, &Condo.migrate_tenant(repo, &1))
      end
    end
  end
end
