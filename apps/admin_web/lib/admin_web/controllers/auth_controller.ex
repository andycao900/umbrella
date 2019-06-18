defmodule AdminWeb.AuthController do
  use AdminWeb, :controller

  alias AdminWeb.Endpoint
  alias AdminWeb.Router.Helpers, as: Routes
  alias Authentication.UserFromAuth
  alias Ueberauth.Strategy.Auth0.OAuth

  plug Ueberauth, otp_app: :admin_web

  defp external_logout_url do
    auth0_url = Application.get_env(:admin_web, OAuth)[:domain]
    client_id = Application.get_env(:admin_web, OAuth)[:client_id]
    root_page_url = Routes.page_url(Endpoint, :index, logged_out: true)

    logout_uri = %URI{
      scheme: "https",
      host: auth0_url,
      path: "/v2/logout/",
      query:
        URI.encode_query(
          client_id: client_id,
          returnTo: root_page_url
        )
    }

    URI.to_string(logout_uri)
  end

  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(external: external_logout_url())
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, gettext("Failed to authenticate."))
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case UserFromAuth.find_or_create(auth, :internal) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("Thanks for logging in! Welcome %{name}", name: user.name))
        |> put_session(:current_user_id, user.id)
        |> configure_session(renew: true)
        |> redirect(to: "/")

      {:error, reason} ->
        IO.inspect(reason)

        conn
        |> put_flash(
          :error,
          gettext(
            "Login Failure. Please retry and if the problem persists contact an administrator."
          )
        )
        |> redirect(to: "/")
    end
  end
end
