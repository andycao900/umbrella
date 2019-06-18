defmodule Authentication.Auth0.Token do
  @moduledoc """
  Represents an [Auth0 API](https://auth0.com/docs/api/info) access token.
  """

  @typedoc """
  * `:access_token` - Auth0 API access token.
  * `:expires_in` - Time before expiration in seconds.
  """
  @type t :: %{
          access_token: String.t(),
          expires_in: integer()
        }
end
