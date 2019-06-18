defmodule Authentication.Plug.RequireAuthentication do
  @moduledoc """
  Authorization plug to require user authentication.

  Usage:

  ```
      pipeline :my_pipeline do
        plug RequireAuthentication, routes_helper: MyAppWeb.Router.Helpers
      end
  ```
  """

  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2]

  def init(opts \\ []) do
    case Keyword.get(opts, :routes_helper) do
      nil -> raise "#{inspect(__MODULE__)} missing routes_helper opt"
      routes_helper -> %{routes_helper: routes_helper}
    end
  end

  def call(%{assigns: %{current_user: nil}} = conn, %{routes_helper: routes_helper}) do
    conn
    |> redirect(to: routes_helper.auth_path(conn, :request))
    |> halt()
  end

  def call(conn, _), do: conn
end
