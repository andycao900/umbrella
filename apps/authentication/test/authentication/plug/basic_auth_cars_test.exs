defmodule Authentication.Plug.BasicAuthTest do
  use ExUnit.Case
  use Phoenix.ConnTest

  alias Authentication.Plug.BasicAuthCars

  @username "some admin"
  @password "some password"

  setup do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def enable_auth do
    Application.put_env(:authentication_test, :basic_auth,
      username: @username,
      password: @password
    )
  end

  def disable_auth do
    Application.put_env(:authentication_test, :basic_auth, nil)
  end

  describe "init/1" do
    test "raises when router_helpers opt missing" do
      assert_raise RuntimeError,
                   "Authentication.Plug.BasicAuthCars missing config_root opt",
                   fn -> BasicAuthCars.init() end
    end

    test "succeeds when config_root is present" do
      enable_auth()

      assert %{basic_auth_options: %BasicAuth.Configured{}} =
               BasicAuthCars.init(config_root: :authentication_test)

      disable_auth()
    end
  end

  describe "call/2" do
    test "when disabled", %{conn: conn} do
      disable_auth()
      config = BasicAuthCars.init(config_root: :authentication_test)
      assert BasicAuthCars.call(conn, config) == conn
    end

    test "redirects with non-authenticated user", %{conn: conn} do
      enable_auth()

      config = BasicAuthCars.init(config_root: :authentication_test)
      conn = BasicAuthCars.call(conn, config)

      assert response(conn, 401)
      disable_auth()
    end
  end
end
