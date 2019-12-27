defmodule Condo.Migrations.CreateBar do
  use Ecto.Migration

  def version, do: 2

  def change do
    create table(:bar) do
      timestamps()
    end
  end
end
