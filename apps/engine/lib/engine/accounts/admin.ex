defmodule Engine.Accounts.Admin do
  @moduledoc """
  Internal representation of Admin model
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.UUID
  alias Engine.Accounts.Admin
  alias Engine.Authorizations.AdminADFSGroup
  alias Engine.Authorizations.AdminRole

  @primary_key {:id, :binary_id, autogenerate: true}

  # 1 or more non-@ non-whitespace chars
  # followed by an @
  # followed by 1 or more non-@ non-whitespace chars
  @email_pattern ~r/^[^@\s]+@[^@\s]+$/

  @allowed_fields ~w(
    email
    first_name
    last_name
    last_signed_in_at
  )a

  @required_fields ~w(email)a

  @typedoc """
  * `:email` - admin email
  * `:first_name` - admin first name
  * `:id` - primary key uuid
  * `:inserted_at` - timestamp of insertion
  * `:last_name` - admin last name
  * `:last_signed_in_at` - utc timestamp of last authentication
  * `:updated_at` - timestamp of last update
  """

  @type t :: %Admin{
          email: String.t(),
          first_name: String.t() | nil,
          id: UUID.t(),
          inserted_at: NaiveDateTime.t(),
          last_name: String.t() | nil,
          last_signed_in_at: DateTime.t() | nil,
          updated_at: NaiveDateTime.t()
        }

  schema "admins" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :last_signed_in_at, :utc_datetime
    many_to_many :roles, Engine.Authorizations.Role, join_through: AdminRole
    many_to_many :adfs_groups, Engine.Authorizations.ADFSGroup, join_through: AdminADFSGroup

    timestamps()
  end

  def changeset(admin \\ %Admin{}, attrs) do
    admin
    |> cast(attrs, @allowed_fields)
    |> validate_required(@required_fields)
    |> validate_format(:email, @email_pattern)
  end
end
