# Since configuration is shared in umbrella projects, this file
# should only configure the :engine application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

config :phoenix, :json_library, Jason

config :engine,
  ecto_repos: [Engine.Repo]

import_config "#{Mix.env()}.exs"
