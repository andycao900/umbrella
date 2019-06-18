defmodule Authentication.Auth0.Behaviour do
  @moduledoc """
  Defines the behaviour of Auth0 API clients.
  """

  alias Authentication.Auth0.{Config, Token}
  alias Authentication.Auth0.User, as: Auth0User
  alias Engine.Accounts.User

  @callback fetch_token(Config.t()) :: {:ok, Token.t()} | {:error, String.t()}
  @callback fetch_user(User.t(), Config.t()) ::
              {:ok, Auth0User.t()} | {:error, Ecto.Changeset.t() | String.t()}
  @callback reset_auth0_password(User.t(), Config.t()) :: :ok | {:error, String.t()}
  @callback users_by_email(String.t(), Config.t()) ::
              {:ok, [Auth0User.t()]} | {:error, String.t()}
  @callback resend_verification_email(User.t(), Config.t()) :: :ok | {:error, String.t()}
  @callback unblock_user(User.t(), Config.t()) :: :ok | {:error, String.t()}
end
