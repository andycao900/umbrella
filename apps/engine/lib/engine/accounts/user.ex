defmodule Engine.Accounts.User do
  @moduledoc """
  Internal representation of User model
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Engine.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  # 1 or more non-@ non-whitespace chars
  # followed by an @
  # followed by 1 or more non-@ non-whitespace chars
  @email_pattern ~r/^[^@\s]+@[^@\s]+$/

  @allowed_fields ~w(
    auth0_id name
    avatar_url
    email
    email_verified
    last_signed_in_at
    type
  )a

  @required_fields ~w(email auth0_id avatar_url type)a

  @typedoc """
  * `:avatar_url` - url for user's avatar (profile image)
  * `:auth0_id` - [auth0](https://auth0.com/) identifier
  * `:email` - user's email
  * `:email_verified` - user email verified in Auth0
  * `:id` - unique ID (primary key)
  * `:last_signed_in_at` - utc timestamp of last authentication
  * `:name` - user's name
  * `:type` - String representation for the type of user. One of 'consumer'
              or 'dealer'.
  """

  @type t :: %User{
          avatar_url: String.t() | nil,
          auth0_id: String.t(),
          email: String.t() | nil,
          email_verified: boolean(),
          id: String.t(),
          last_signed_in_at: DateTime.t() | nil,
          name: String.t() | nil,
          type: String.t() | nil
        }

  schema "users" do
    field :avatar_url, :string
    field :auth0_id, :string
    field :email, :string
    field :email_verified, :boolean, default: false
    field :last_signed_in_at, :utc_datetime
    field :name, :string
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @allowed_fields)
    |> validate_required(@required_fields)
    |> validate_format(:email, @email_pattern)
    |> validate_inclusion(:type, ["consumer", "dealer", "internal"])
  end
end
