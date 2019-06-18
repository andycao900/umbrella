# Since configuration is shared in umbrella projects, this file
# should only configure the :admin_web application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

config :authentication, auth0_api: Authentication.Auth0.Mock
