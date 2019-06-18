defmodule Engine.Authorizations.AdminRole do
  @moduledoc """
  Internal representation of user role model
  """
  use Ecto.Schema
  alias Ecto.UUID
  alias Engine.Accounts.Admin
  alias Engine.Authorizations.{AdminRole, Role}

  @primary_key {:id, :binary_id, autogenerate: true}

  @typedoc """
  * `:admin_id` - Owner
  * `:admin` - `t:Engine.Accounts.Admin.t/0`
  * `:id` - primary key uuid
  * `:inserted_at` - timestamp of insertion
  * `:role_id` - Role
  * `:role` - `t:Engine.Authorizations.Role.t/0`
  * `:updated_at` - timestamp of last update
  """

  @type t :: %AdminRole{
          admin_id: UUID.t(),
          admin: [Admin.t()] | Ecto.Association.NotLoaded.t(),
          role: [Role.t()] | Ecto.Association.NotLoaded.t(),
          role_id: UUID.t()
        }

  schema "admin_roles" do
    belongs_to :admin, Admin, type: :binary_id
    belongs_to :role, Role, type: :binary_id

    timestamps()
  end
end
