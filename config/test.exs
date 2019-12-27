use Mix.Config

config :condo, Condo.TestRepo,
  username: "postgres",
  password: "postgres",
  database: "condo_test",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 20

config :condo, migration_namespace: "Condo.Migrations"

config :logger, level: :warn
