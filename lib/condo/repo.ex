defmodule Condo.Repo do
  @moduledoc """
  This repo is very similar to `Ecto.Repo` but instead of being a module to be
  extended, it's a module meant to be used to map tenants to database instances
  in case you are sharding tenants. It also provides feature parity with
  `Ecto.Repo` by using meta-programming and adding the prefix into the options.

  ## A Note on Replicas

  Please note that we did not include some functions in the tenant to repo
  mapper since they tend to map to different server instances. If you have a
  repo and different DB instances which are replicated, then you could risk
  starting a transaction on one server and closing it on another. To avoid this,
  we simply do not allow you (it's a sneaky problem) and instead recommend to
  use a little less sugar. Here's an example if `Ecto.Repo.stream/3` and
  `Ecto.Repo.transaction/2` were implemented:

      # Grab a stream from `Repo.Foo.Replica1`
      stream = Condo.Repo.stream(User, :foo)

      # Start a transaction on `Repo.Foo.Replica2`
      Condo.Repo.transaction(fn -> Enum.to_list(stream) end, :foo)

  Instead, Condo recommends that you lookup the repo first and then run your
  transactions:

      repo = Condo.Repo.repo(:foo)
      stream = repo.stream(User, prefix: Condo.prefix(:foo))
      repo.transaction(fn -> Enum.to_list(stream) end, prefix: Condo.prefix(:foo))

  This is far more safe and allows you to scale to read replicas in the future.
  Functions from `Ecto.Repo` not implemented:

    - checkout/2
    - in_transaction?/0
    - rollback/1
    - stream/2
    - transaction/2
  """

  @two_arity_fns ~w(
    all delete delete! delete_all exists? insert insert! insert_or_update
    insert_or_update! one one! update update!
  )a

  @three_arity_fns ~w(
    get get! get_by get_by! insert_all preload prepare_query update_all
  )a

  @four_arity_fns ~w(aggregate)a

  for method <- @two_arity_fns do
    def unquote(method)(first_arg, tenant, opts \\ []) do
      tenant
      |> repo()
      |> Kernel.apply(unquote(method), [first_arg, put_prefix(tenant, opts)])
    end
  end

  for method <- @three_arity_fns do
    def unquote(method)(first_arg, second_arg, tenant, opts \\ []) do
      tenant
      |> repo()
      |> Kernel.apply(unquote(method), [first_arg, second_arg, put_prefix(tenant, opts)])
    end
  end

  for method <- @four_arity_fns do
    def unquote(method)(first_arg, second_arg, third_arg, tenant, opts \\ []) do
      tenant
      |> repo()
      |> Kernel.apply(unquote(method), [
        first_arg,
        second_arg,
        third_arg,
        put_prefix(tenant, opts)
      ])
    end
  end

  defp put_prefix(tenant, opts) do
    Keyword.put_new(opts, :prefix, Condo.prefix(tenant))
  end

  @spec repo(Condo.tenant()) :: module()
  def repo(tenant) do
    case Application.fetch_env(:condo, :repo_mapper) do
      {:ok, {module, function_name}} -> apply(module, function_name, [tenant])
      {:ok, repo} when is_atom(repo) -> repo
      {:ok, function} when is_function(function) -> function.(tenant)
      :error -> raise "`repo_mapper` config must be a module or a function"
    end
  end
end
