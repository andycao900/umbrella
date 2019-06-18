defmodule AdminWeb.Plug.RequirePermission do
  @moduledoc """
  Authorization plug for restricting access to controller actions based on user permissions.
  """

  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  alias AdminWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  @doc """
  No-op if user has required permission, otherwise redirects to `AdminWeb`'s home page.
  """
  def call(%{assigns: %{current_user: user}} = conn, permission_name) do
    IO.inspect("---->here")

    if authorized?(user, permission_name) do
      conn
    else
      IO.inspect(conn)

      conn
      |> put_flash(:error, "You aren't authorized to perform this action.")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  def authorized?(user, permission_name) do
    permission_name in user_permission_names(user)
  end

  defp user_permission_names(user) do
    for role <- user.roles,
        permission <- role.permissions do
      permission.name
    end
  end
end
