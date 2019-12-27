use Mix.Config

config :condo, ecto_repos: [Condo.TestRepo]

import_config "#{Mix.env()}.exs"
