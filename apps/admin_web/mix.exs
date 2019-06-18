defmodule AdminWeb.MixProject do
  use Mix.Project

  def project do
    [
      app: :admin_web,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {AdminWeb.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.11"},
      # connects to new relic for apm
      {:new_relic_agent, "~> 1.0"},
      # add phoenix specific instrumentation on top of the new_relic_agent
      {:new_relic_phoenix, "~> 0.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      # HTTPoison provides functions for making HTTP requests
      {:httpoison, "~> 1.5"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:authentication, in_umbrella: true},

      # Plug to easily add HTTP basic authentication to an app
      {:basic_auth, "~> 2.2.2"},
      {:engine, in_umbrella: true},
      {:ueberauth, "~> 0.6.1"},
      # provides Auth0 OAuth2 strategy for Überauth
      {:ueberauth_auth0, git: "https://github.com/sabondano/ueberauth_auth0.git"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, we extend the test task to create and migrate the database.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [test: ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
