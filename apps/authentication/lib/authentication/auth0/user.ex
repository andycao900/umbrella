defmodule Authentication.Auth0.User do
  @moduledoc """
  Represents user details as returned by the Auth0 Management API.

  For more information see:
  https://auth0.com/docs/api/management/v2#!/Users/get_users_by_id
  """

  use Ecto.Schema
  import Ecto.Changeset

  @typedoc """
  * `:email` - user email address
  * `:email_verified` - indicates if email was verified
  * `:user_id` - user's primary ID on Auth0
  """

  @type t :: %__MODULE__{
          email: String.t() | nil,
          user_id: String.t(),
          email_verified: boolean()
        }

  @required_fields ~w(
    email
    email_verified
    user_id
  )a

  @primary_key false

  embedded_schema do
    field(:email, :string)
    field(:email_verified, :boolean)
    field(:user_id, :string)
  end

  def validate(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> apply_action(:update)
  end

  defp changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
