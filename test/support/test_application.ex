defmodule Condo.TestApplication do
  @moduledoc false

  use Application

  def start(_type, _args) do
    Supervisor.start_link([Condo.TestRepo], strategy: :one_for_one, name: Condo.Supervisor)
  end
end
