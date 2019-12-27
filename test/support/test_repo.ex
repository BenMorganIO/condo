defmodule Condo.TestRepo do
  use Ecto.Repo,
    otp_app: :condo,
    adapter: Ecto.Adapters.Postgres
end
