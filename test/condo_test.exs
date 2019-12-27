defmodule CondoTest do
  use ExUnit.Case, async: false

  alias Condo.TestRepo, as: Repo
  alias Condo.Migrations

  doctest Condo

  setup do
    :code.ensure_loaded(Migrations.CreateFoo)
    :code.ensure_loaded(Migrations.CreateBar)
    :ok
  end

  describe "new_tenant/2" do
    setup do
      drop_schema(:test)
      :ok
    end

    test "will create a new schema and run migrations" do
      Condo.new_tenant(Repo, :test)

      assert {:ok, %Postgrex.Result{num_rows: 1}} =
               query(
                 "SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'tenant_test'"
               )

      assert {:ok, %Postgrex.Result{rows: [["schema_migrations"]]}} =
               query(
                 "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'"
               )

      {:ok, %Postgrex.Result{rows: rows}} =
        query(
          "SELECT table_name FROM information_schema.tables WHERE table_schema = 'tenant_test'"
        )

      assert Enum.sort(rows) == [["bar"], ["foo"], ["schema_migrations"]]
    end
  end

  describe "drop_tenant/2" do
    setup do
      drop_schema(:test)

      Condo.new_tenant(Repo, :test)

      assert {:ok, %Postgrex.Result{num_rows: 1}} =
               query(
                 "SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'tenant_test'"
               )

      :ok
    end

    test "will remove a schema" do
      Condo.drop_tenant(Repo, :test)

      assert {:ok, %Postgrex.Result{num_rows: 0}} =
               query(
                 "SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'tenant_test'"
               )
    end
  end

  describe "rollback_tenant/2" do
    setup do
      drop_schema(:test)

      Condo.new_tenant(Repo, :test)

      {:ok, %Postgrex.Result{rows: rows}} =
        query(
          "SELECT table_name FROM information_schema.tables WHERE table_schema = 'tenant_test'"
        )

      assert Enum.sort(rows) == [["bar"], ["foo"], ["schema_migrations"]]

      :ok
    end

    test "will roll back a migration" do
      Condo.rollback_tenant(Repo, :test)

      {:ok, %Postgrex.Result{rows: rows}} =
        query(
          "SELECT table_name FROM information_schema.tables WHERE table_schema = 'tenant_test'"
        )

      assert Enum.sort(rows) == [["foo"], ["schema_migrations"]]
    end
  end

  defp drop_schema(tenant), do: query("DROP SCHEMA \"tenant_#{tenant}\" CASCADE")

  defp query(sql, opts \\ []), do: Ecto.Adapters.SQL.query(Repo, sql, opts, log: false)
end
