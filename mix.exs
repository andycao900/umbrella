defmodule CarsUmbrella.MixProject do
  use Mix.Project

  def project do
    [
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
      {:git_hooks, "~> 0.2.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10.6", only: :test},
      {:credo, "~> 1.0.2", only: :dev, runtime: false},
      {:mix_test_watch, "~> 0.9.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.4", only: :dev, runtime: false},
      {:earmark, "~> 1.3.1", only: :dev, runtime: false},
      {:ex_doc, "~> 0.19.3", only: :dev, runtime: false}
    ]
  end
end
