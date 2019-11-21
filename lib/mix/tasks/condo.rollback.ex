defmodule Mix.Tasks.Condo.Rollback do
  use Mix.Task

  import Mix.Ecto

  @shortdoc "Rollsback the latest migration for each tenant."

  def run(args) do
    no_umbrella!("condo.rollback")
    repos = parse_repo(args)

    Enum.each(repos, fn repo ->
      Ecto.Migrator.with_repo(repo, fn repo ->
        stream = repo.stream(repo.tenant_ids)

        repo.transaction(fn ->
          Enum.each(stream, &Condo.rollback_tenant(repo, &1))
        end)
      end)
    end)
  end
end
