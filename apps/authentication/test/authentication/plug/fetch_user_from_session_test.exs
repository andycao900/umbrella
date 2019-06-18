defmodule Authentication.Plug.FetchUserFromSessionTest do
  use ExUnit.Case
  import Plug.Conn, only: [put_session: 3, fetch_session: 1, get_session: 2]
  alias Authentication.Plug.FetchUserFromSession

  @default_session_opts [
    store: :cookie,
    key: "foobar",
    encryption_salt: "encrypted cookie salt",
    signing_salt: "signing salt",
    log: false
  ]

  setup do
    conn =
      Phoenix.ConnTest.build_conn()
      |> Plug.Session.call(Plug.Session.init(@default_session_opts))
      |> fetch_session()

    {:ok, conn: conn, config: FetchUserFromSession.init(user_resolver: &user_resolver/1)}
  end

  def user_resolver(id) do
    %{id: id}
  end

  describe "init/1" do
    test "fails when missing user_resolver" do
      assert_raise RuntimeError,
                   "Authentication.Plug.FetchUserFromSession missing user_resolver opt",
                   fn ->
                     FetchUserFromSession.init()
                   end
    end

    test "succeeds when user_resolver is there" do
      assert %{user_resolver: _} = FetchUserFromSession.init(user_resolver: &user_resolver/1)
    end
  end

  describe "call/2" do
    test "when we have a valid current_user_id it fetches the logged in user", %{
      conn: conn,
      config: config
    } do
      result =
        conn
        |> put_session(:current_user_id, 42)
        |> FetchUserFromSession.call(config)

      assert %{current_user: %{id: 42}} = result.assigns
    end

    test "when no current_user_id in session, it passes the original connection", %{
      conn: conn,
      config: config
    } do
      assert get_session(conn, :current_user_id) == nil
      result = FetchUserFromSession.call(conn, config)

      assert %{current_user: nil} = result.assigns
    end
  end
end
