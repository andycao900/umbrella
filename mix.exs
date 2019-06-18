defmodule CarsUmbrella.MixProject do
  use Mix.Project

  def project do
    [
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore.exs",
        list_unused_filters: true,
        plt_file: {:no_warn, "cars_umbrella.plt"}
      ],
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:credo, "~> 1.0.5", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test], runtime: false},
      {:distillery, "2.0.12", runtime: false},
      # provides conveniences for filtering and casting data from 3rd party APIs
      {:ecto, "~> 3.0"},
      {:ex_doc, "~> 0.19", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10.6", only: :test},
      {:faker, "~> 0.12", only: :test},
      {:git_hooks, "~> 0.3.0", only: :dev, runtime: false},
      {:inch_ex, "~> 2.0.0", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 0.9.0", only: :dev, runtime: false},
      {:umbrella_streamline_formatter, "~> 0.1.0"}
    ]
  end

  defp aliases do
    [
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.reset.test": ["ecto.drop", "ecto.setup"],
      "git.check": ["git_hooks.run all"],
      "npm.install": [
        "cmd --app admin_web  'npm install --prefix assets'"
        # "cmd --app cars_web --app admin_web --app dealer_web 'npm install --prefix assets'"
      ],
      "npm.lint": ["cmd --app cars_web 'npm run lint --prefix assets'"],
      "npm.test": [
        "cmd --app cars_web --app admin_web --app dealer_web 'npm test --prefix assets'"
      ],
      "npm.version_check": "run --no-start npm_version_check.exs",
      "secret.copy_example": [
        "cmd --app engine --app cars_web --app admin_web --app dealer_web --app manifold mix secret.copy_example"
      ],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      coverage_report: [&coverage_report/1],
      "docs.all": [
        "run --no-start tasks/umbrella_docs/umbrella_docs.exs --prepare",
        "docs",
        ~s{cmd "mix docs"}
      ]
    ] ++ aliases(Mix.env())
  end

  defp coverage_report(_) do
    Mix.Task.run("coveralls.html", ["--umbrella"])

    open_cmd =
      case :os.type() do
        {:win32, _} ->
          "start"

        {:unix, :darwin} ->
          "open"

        {:unix, _} ->
          "xdg-open"
      end

    System.cmd(open_cmd, ["cover/excoveralls.html"])
  end

  defp aliases(:dev),
    do: ["ecto.setup": ["ecto.create", "ecto.migrate", "run apps/engine/priv/repo/seeds.exs"]]

  defp aliases(_), do: ["ecto.setup": ["ecto.create", "ecto.migrate"]]

  defp docs() do
    [
      main: "umbrella-readme",
      api_reference: false,
      assets: "tasks/umbrella_docs/assets",
      extras: ["umbrella-readme.md"],
      before_closing_head_tag: fn :html ->
        ~S{<link rel="stylesheet" href="./assets/custom_styles.css">}
      end
    ]
  end
end
