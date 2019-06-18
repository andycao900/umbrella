defmodule Engine.Authorizations.Permission do
  @moduledoc """
  Internal representation of Permissions model
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.UUID
  alias Engine.Authorizations.{Permission, Role, RolePermission}

  @primary_key {:id, :binary_id, autogenerate: true}

  @required_fields ~w(name)a

  @typedoc """
  * `:id` - primary key uuid
  * `:inserted_at` - timestamp of insertion
  * `:name` - name of permission
  * `:roles` - list of t:Engine.Authorizations.Role.t/0s associated to permission
  * `:updated_at` - timestamp of last update
  """

  @type t :: %Permission{
          id: UUID.t(),
          inserted_at: NaiveDateTime.t(),
          name: String.t(),
          roles: [Role.t()] | Ecto.Association.NotLoaded.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "permissions" do
    field :name, :string
    many_to_many :roles, Engine.Authorizations.Role, join_through: RolePermission
    timestamps()
  end

  def changeset(permission \\ %Permission{}, attrs) do
    permission
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
