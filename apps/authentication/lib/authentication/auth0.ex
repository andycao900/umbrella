defmodule Authentication.Auth0 do
  @moduledoc """
  Public interface for our Auth0 API client.
  """

  @behaviour Authentication.Auth0.Behaviour

  alias __MODULE__.TokenStore

  def reset_auth0_password(user, config) do
    auth0_api().reset_auth0_password(user, config)
  end

  def resend_verification_email(user, config) do
    auth0_api().resend_verification_email(user, config)
  end

  def fetch_token(config) do
    TokenStore.fetch_token(auth0_api(), config)
  end

  def fetch_user(user, config) do
    auth0_api().fetch_user(user, config)
  end

  def users_by_email(email, config) do
    auth0_api().users_by_email(email, config)
  end

  def unblock_user(user, config) do
    auth0_api().unblock_user(user, config)
  end

  defp auth0_api do
    Application.get_env(:authentication, :auth0_api, Authentication.Auth0.HTTPClient)
  end
end
