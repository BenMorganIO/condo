defmodule Mix.Tasks.Condo.Gen.Migration do
  @moduledoc """
  Generates a migration for the tenants. Please ensure that you have set
  `:migration_namespace` for Condo as well.

  The repository must be set under `:ecto_repos` in the current app
  configuration or given via the `-r` option.

  By default, the migration will be generated in the namespace you have
  provided.

  ## Examples

      mix condo.gen.migration create_posts
      mis condo.gen.migration create_posts -r Custom.Repo

  ## Command line options
    * `-r`, `--repo` - the repo to generate migration for
  """

  use Mix.Task

  import Macro, only: [camelize: 1, underscore: 1]
  import Mix.Generator
  import Mix.Ecto

  alias Condo.Migration

  @shortdoc "Generates a new migration for the tenants"
  @switches [change: :string]

  @doc false
  def run(args) do
    no_umbrella!("condo.gen.migration")
    repos = parse_repo(args)
    timestamp = create_timestamp()

    repos
    |> Enum.map(fn repo ->
      ensure_repo(repo, args)

      case OptionParser.parse(args, switches: @switches) do
        {opts, [name], _} ->
          path = underscore(Migration.namespace())
          relative_path = Path.relative_to("lib/#{path}", Mix.Project.app_path())
          {relative_path, name, opts}

        {_, _, _} ->
          Mix.raise(
            "expected cond.gen.migration to receive the migration " <>
              "file name, got: #{inspect(Enum.join(args, " "))}"
          )
      end
    end)
    |> Enum.uniq()
    |> Enum.each(fn {path, name, opts} -> write_migration(path, timestamp, name, opts) end)
  end

  defp write_migration(relative_path, timestamp, name, opts) do
    create_directory(relative_path)
    file = Path.join(relative_path, "#{timestamp}_#{underscore(name)}.ex")

    assigns = [
      change: opts[:change],
      name: camelize(name),
      namespace: Migration.namespace(),
      timestamp: timestamp
    ]

    create_file(file, migration_template(assigns))
  end

  defp create_timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: <<?0, ?0 + i>>
  defp pad(i), do: to_string(i)

  embed_template(:migration, """
  defmodule <%= @namespace %>.<%= @name %> do
    use Ecto.Migration

    def version, do: <%= @timestamp %>

    def change do
  <%= @change %>
    end
  end
  """)
end
