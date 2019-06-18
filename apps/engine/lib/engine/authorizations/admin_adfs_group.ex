defmodule Engine.Authorizations.AdminADFSGroup do
  @moduledoc """
  Internal representation of AdminADFSGroup model
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.UUID
  alias Engine.Accounts.Admin
  alias Engine.Authorizations.{ADFSGroup, AdminADFSGroup}

  @primary_key {:id, :binary_id, autogenerate: true}

  @required_fields ~w(adfs_group_id admin_id)a

  @typedoc """
  * `:adfs_group_id` - id of adfs group
  * `:adfs_group` - `t:Engine.Authorizations.ADFSGroup.t/0` the associated admin belongs to
  * `:admin_id` - id of admin
  * `:admin` - `t:Engine.Accounts.Admin.t/0` that belongs to the associated ADFS Group
  * `:id` - primary key uuid
  * `:inserted_at` - timestamp of insertion
  * `:updated_at` - timestamp of last update
  """

  @type t :: %AdminADFSGroup{
          adfs_group: [ADFSGroup.t()] | Ecto.Association.NotLoaded.t(),
          adfs_group_id: UUID.t(),
          admin: [Admin.t()] | Ecto.Association.NotLoaded.t(),
          admin_id: UUID.t(),
          id: UUID.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "admin_adfs_groups" do
    belongs_to :admin, Admin, type: :binary_id
    belongs_to :adfs_group, ADFSGroup, type: :binary_id
    timestamps()
  end

  def changeset(admin_adfs_group \\ %AdminADFSGroup{}, attrs) do
    admin_adfs_group
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
