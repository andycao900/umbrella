defmodule AdminWeb.Users.BlockController do
  use AdminWeb, :controller

  alias AdminWeb.Auth0
  alias Engine.Accounts

  def delete(conn, %{"user_id" => user_id}) do
    user = Accounts.get_user!(user_id)

    case Auth0.unblock_user(user) do
      :ok ->
        conn
        |> put_flash(:success, "User unblocked successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, reason} ->
        conn
        |> put_flash(:error, "Error while unblocking: #{reason}")
        |> redirect(to: Routes.user_path(conn, :show, user))
    end
  end
end
