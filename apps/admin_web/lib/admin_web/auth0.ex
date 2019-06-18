defmodule AdminWeb.Auth0 do
  @moduledoc """
  Convenience functions for working with Authentication.Auth0 module.
  """

  alias Authentication.Auth0
  alias Authentication.Auth0.Config

  oauth_config = Application.fetch_env!(:admin_web, Ueberauth.Strategy.Auth0.OAuth)
  base_url = "https://" <> Keyword.get(oauth_config, :domain, "")
  config_keyword = Keyword.merge(oauth_config, base_url: base_url)
  @config struct(Config, config_keyword)

  def unblock_user(user) do
    Auth0.unblock_user(user, @config)
  end

  def reset_auth0_password(user) do
    Auth0.reset_auth0_password(user, @config)
  end
end
