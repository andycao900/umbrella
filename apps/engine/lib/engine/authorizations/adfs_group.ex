defmodule Engine.Authorizations.ADFSGroup do
  @moduledoc """
  Internal representation of ADFSGroup model
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.UUID
  alias Engine.Authorizations.{ADFSGroup, AdminADFSGroup}

  @primary_key {:id, :binary_id, autogenerate: true}

  @required_fields ~w(name remote_adfs_group_id)a

  @typedoc """
  * `:id` - primary key uuid
  * `:inserted_at` - timestamp of insertion
  * `:name` - name of adfs group
  * `:remote_adfs_group_id` - id of adfs group coming from cars internal adfs system
  * `:updated_at` - timestamp of last update
  """

  @type t :: %ADFSGroup{
          id: UUID.t(),
          inserted_at: NaiveDateTime.t(),
          name: String.t(),
          remote_adfs_group_id: UUID.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "adfs_groups" do
    field :remote_adfs_group_id, :binary_id
    field :name, :string
    many_to_many :admins, Engine.Accounts.Admin, join_through: AdminADFSGroup
    timestamps()
  end

  def changeset(adfs_group \\ %ADFSGroup{}, attrs) do
    adfs_group
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
