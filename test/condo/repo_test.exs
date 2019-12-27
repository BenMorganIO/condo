defmodule Condo.RepoTest do
  use ExUnit.Case, async: false

  alias Condo.Repo

  describe "repo/1" do
    test "will return test repo when a tuple is provided" do
      Application.put_env(:condo, :repo_mapper, {__MODULE__, :map_repo})

      assert Repo.repo(:foo) == Condo.TestRepo
    end

    test "will return test repo when a module is provided" do
      Application.put_env(:condo, :repo_mapper, Condo.TestRepo)

      assert Repo.repo(:foo) == Condo.TestRepo
    end

    test "will return test repo when a function is provided" do
      Application.put_env(:condo, :repo_mapper, fn tenant ->
        assert tenant == :foo

        Condo.TestRepo
      end)

      assert Repo.repo(:foo) == Condo.TestRepo
    end

    test "will raise an error when not configured" do
      Application.delete_env(:condo, :repo_mapper)

      assert_raise(RuntimeError, fn -> Repo.repo(:foo) end)
    end
  end

  def map_repo(tenant) do
    assert tenant == :foo
    Condo.TestRepo
  end
end
