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

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
