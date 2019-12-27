defmodule Condo.Migrations.CreateFoo do
  use Ecto.Migration

  def version, do: 1

  def change do
    create table(:foo) do
      timestamps()
    end
  end
end
