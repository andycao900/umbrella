defmodule Authentication.Auth0Test do
  use ExUnit.Case

  import Mox

  alias Authentication.Auth0
  alias Authentication.Auth0.{Config, TokenStore}
  alias Authentication.Auth0.Mock, as: Auth0Mock

  setup :verify_on_exit!

  setup do
    {:ok, user: "some user", config: "some config"}
  end

  describe "reset_auth0_password/2" do
    test "calls configured module with same args", %{user: user, config: config} do
      expect(Auth0Mock, :reset_auth0_password, fn ^user, ^config ->
        :ok
      end)

      assert Auth0.reset_auth0_password(user, config) == :ok
    end
  end

  describe "resend_verification_email/2" do
    test "calls configured module with same args", %{user: user, config: config} do
      expect(Auth0Mock, :resend_verification_email, fn ^user, ^config ->
        :ok
      end)

      assert Auth0.resend_verification_email(user, config) == :ok
    end
  end

  describe "fetch_token/1" do
    test "calls configured module with same args" do
      token = "some token"
      config = %Config{otp_app: :some_app}

      :ok = GenServer.call(TokenStore, {:insert, {token, config}})

      assert Auth0.fetch_token(config) == {:ok, token}

      send(TokenStore, :delete_all)
      # ensure delete_all above is done before exiting test
      :sys.get_state(TokenStore)
    end
  end

  describe "fetch_user/2" do
    test "calls configured module with same args", %{user: user, config: config} do
      expect(Auth0Mock, :fetch_user, fn ^user, ^config ->
        {:ok, user}
      end)

      assert Auth0.fetch_user(user, config) == {:ok, user}
    end
  end

  describe "users_by_email/2" do
    test "calls configured module with same args", %{user: user, config: config} do
      expect(Auth0Mock, :users_by_email, fn ^user, ^config ->
        {:ok, []}
      end)

      assert Auth0.users_by_email(user, config) == {:ok, []}
    end
  end

  describe "unblock_user/2" do
    test "calls configured module with same args", %{user: user, config: config} do
      expect(Auth0Mock, :unblock_user, fn ^user, ^config ->
        :ok
      end)

      assert Auth0.unblock_user(user, config) == :ok
    end
  end
end
