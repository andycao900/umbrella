defmodule Authentication.Plug.BasicAuthCars do
  @moduledoc """
  Plug for enabling basic authentication. Uses 3rd party `BasicAuth` module hence the `Cars` suffix.

  Must specify config root. For example:

  ```
      plug BasicAuthCars, config_root: :myapp_web
  ```

  will retrieve config from:

  ```
  config :myapp_web,
    basic_auth: [
      username: "admin",
      password: "hunter2"
    ]
  ```
  """

  def init(opts \\ []) do
    case Keyword.get(opts, :config_root) do
      nil ->
        raise "#{inspect(__MODULE__)} missing config_root opt"

      config_root ->
        if Application.get_env(config_root, :basic_auth) == nil do
          %{}
        else
          %{basic_auth_options: BasicAuth.init(use_config: {config_root, :basic_auth})}
        end
    end
  end

  def call(conn, %{basic_auth_options: basic_auth_options}) do
    BasicAuth.call(conn, basic_auth_options)
  end

  def call(conn, _), do: conn
end
