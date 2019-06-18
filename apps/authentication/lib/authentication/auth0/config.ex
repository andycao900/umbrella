defmodule Authentication.Auth0.Config do
  @moduledoc """
  Represents a struct of Auth0 application specific configurations
  """

  defstruct ~w(base_url client_id client_secret domain otp_app)a

  @typedoc """
  * `:base_url` - URL of the management API
  * `:client_id` - id of Auth0 client
  * `:client_secret` - secret of Auth0 Client
  * `:domain` - URL of the Auth0 tenant
  * `:otp_app` - Atom of the calling otp app. Used to map tokens back to the correct app

  """

  @type t :: %__MODULE__{
          base_url: String.t() | nil,
          client_id: String.t() | nil,
          client_secret: String.t() | nil,
          domain: String.t() | nil,
          otp_app: atom() | nil
        }
end
