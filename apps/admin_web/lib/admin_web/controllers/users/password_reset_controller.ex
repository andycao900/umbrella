defmodule AdminWeb.Users.PasswordResetController do
  use AdminWeb, :controller

  alias AdminWeb.Auth0
  alias Engine.Accounts

  def create(conn, %{"user_id" => user_id}) do
    user = Accounts.get_user!(user_id)

    case Auth0.reset_auth0_password(user) do
      :ok ->
        conn
        |> put_flash(
          :success,
          gettext("Password Change email has been sent to the user")
        )
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, _reason} ->
        conn
        |> put_flash(
          :error,
          gettext("Sorry, we are unable to process the password change request at this time.
        Please try again later.")
        )
        |> redirect(to: Routes.user_path(conn, :show, user))
    end
  end
end
