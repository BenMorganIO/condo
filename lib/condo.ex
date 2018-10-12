defmodule Condo do
  defdelegate drop_tenant(repo, tenant), to: Condo.TenantActions
  defdelegate migrate_tenant(repo, tenant), to: Condo.TenantActions
  defdelegate new_tenant(repo, tenant), to: Condo.TenantActions
  defdelegate prefix(repo, tenant), to: Condo.TenantActions
  defdelegate schema_prefix(tenant), to: Condo.TenantActions
end
