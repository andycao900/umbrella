defmodule Utils.Auth.RequireAuthenticationTest do
  use ExUnit.Case
  use Phoenix.ConnTest

  alias Authentication.Plug.RequireAuthentication

  setup do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  defmodule RouterHelpers do
    def auth_path(_, :request) do
      "/an_auth_path"
    end
  end

  describe "init/1" do
    test "raises when router_helpers opt missing" do
      assert_raise RuntimeError,
                   "Authentication.Plug.RequireAuthentication missing routes_helper opt",
                   fn -> RequireAuthentication.init() end
    end

    test "succeeds when router_helpers is present" do
      RequireAuthentication.init(routes_helper: RouterHelpers)
    end
  end

  describe "call/2" do
    test "with authenticated user", %{conn: conn} do
      conn = assign(conn, :current_user, :foo)

      assert RequireAuthentication.call(conn, %{routes_helper: RouterHelpers}) == conn
    end

    test "redirects with non-authenticated user", %{conn: conn} do
      conn =
        conn
        |> assign(:current_user, nil)
        |> RequireAuthentication.call(%{routes_helper: RouterHelpers})

      assert redirected_to(conn, 302) =~ RouterHelpers.auth_path(conn, :request)
    end
  end
end
