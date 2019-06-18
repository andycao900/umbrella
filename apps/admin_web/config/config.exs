# Since configuration is shared in umbrella projects, this file
# should only configure the :admin_web application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# General application configuration
config :admin_web,
  # ecto_repos: [AdminWeb.Repo],
  # generators: [context_app: false]
  ecto_repos: [Engine.Repo],
  generators: [context_app: :engine]

# Configures the endpoint
config :admin_web, AdminWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Ebps0j50YR6/hX0mvEjFJcKigYWYrq5c4TZEBjrlJoMZsw+O3T8SNPsQusMfaD7N",
  render_errors: [view: AdminWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: AdminWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures oauth2 to use Jason JSON parser instead of default poison
config :oauth2,
  serializers: %{
    "application/json" => Jason
  }

# Configures Ueberauth
config :admin_web, Ueberauth,
  base_path: "/login",
  providers: [
    auth0:
      {Ueberauth.Strategy.Auth0,
       [otp_app: :admin_web, request_path: "/login/", callback_path: "/login/callback"]}
  ]

# configures AdminWeb.API.MicrosoftGraph.HTTPClient
config :admin_web, :microsoft_graph_api, base_url: "https://graph.microsoft.com/v1.0"

# configures Microsoft OAuth2
config :admin_web, :microsoft_oauth,
  token_url: "https://login.microsoftonline.com/cars.com/oauth2/v2.0/token"

# list ADFS group ID numbers
config :admin_web,
  adfs_groups: %{
    # currently id's are for non-prod only
    customer_service_admin: "6627baff-4340-4bc5-9613-2da4c37a12a0",
    customer_service_member: "07dd1b57-d20f-4431-b158-dc47c11d0bee",
    team_beta: "0781d18a-11fa-403b-903e-f8f687379a09"
  }

# enables NewRelic
config :admin_web, AdminWeb.Endpoint, instrumenters: [NewRelic.Phoenix.Instrumenter]

# configures otp app name to use for token store
config :admin_web, Ueberauth.Strategy.Auth0.OAuth, otp_app: :admin_web

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
