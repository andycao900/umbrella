defmodule Engine.Authorizations.Role do
  @moduledoc """
  Internal representation of role model
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.UUID
  alias Engine.Accounts.Admin
  alias Engine.Authorizations.{AdminRole, Permission, Role, RolePermission}

  @primary_key {:id, :binary_id, autogenerate: true}

  @required_fields ~w(name)a

  @typedoc """
  * `:admins` - list of `t:Engine.Accounts.Admin.t/0`s that belong to role
  * `:id` - primary key uuid
  * `:inserted_at` - timestamp of insertion
  * `:name` - name of role
  * `:permissions` - list of `t:Engine.Authorizations.Permission.t/0` associated to role
  * `:updated_at` - timestamp of last update
  """

  @type t :: %Role{
          admins: [Admin.t()] | Ecto.Association.NotLoaded.t(),
          id: UUID.t(),
          inserted_at: NaiveDateTime.t(),
          name: String.t(),
          permissions: [Permission.t()] | Ecto.Association.NotLoaded.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "roles" do
    field :name, :string
    many_to_many :permissions, Engine.Authorizations.Permission, join_through: RolePermission
    many_to_many :admins, Engine.Accounts.Admin, join_through: AdminRole
    timestamps()
  end

  def changeset(role \\ %Role{}, attrs) do
    role
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
