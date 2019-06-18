defmodule Engine.Authorizations.RolePermission do
  @moduledoc """
  Internal representation of user role model
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.UUID
  alias Engine.Authorizations.{Permission, Role, RolePermission}

  @primary_key {:id, :binary_id, autogenerate: true}

  @required_fields ~w(role_id permission_id)a

  @typedoc """
  * `:id` - primary key uuid
  * `:inserted_at` - timestamp of insertion
  * `:permission` - t:Engine.Authorizations.Permission.t/0 associated to role_permission
  * `:permission_id` - Permission ID uuid
  * `:role` - t:Engine.Authorizations.Role.t/0 associated to role_permission
  * `:role_id` - Role ID uuid
  * `:updated_at` - timestamp of last update
  """

  @type t :: %RolePermission{
          id: UUID.t(),
          inserted_at: NaiveDateTime.t(),
          permission: Permission.t() | Ecto.Association.NotLoaded.t(),
          permission_id: UUID.t(),
          role: Role.t() | Ecto.Association.NotLoaded.t(),
          role_id: UUID.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "role_permissions" do
    belongs_to(:permission, Permission, type: :binary_id)
    belongs_to(:role, Role, type: :binary_id)

    timestamps()
  end

  def changeset(role_permission \\ %RolePermission{}, attrs) do
    role_permission
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
