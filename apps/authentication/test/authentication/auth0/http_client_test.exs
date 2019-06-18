defmodule Authentication.Auth0.HTTPClientTest do
  use Engine.DataCase, async: false

  import ExUnit.CaptureLog
  import Mox

  alias Authentication.Auth0.{Config, HTTPClient, Mock, TokenStore, User}
  alias Authentication.Auth0.Mock
  alias Authentication.Auth0.TokenStore
  alias Authentication.Auth0.User

  @auth0_user_payload %{
    "email" => "jon@doe.com",
    "email_verified" => true,
    "user_id" => "auth0|1234"
  }

  setup :verify_on_exit!
  setup :set_mox_global

  setup do
    bypass = Bypass.open()
    user = insert(:user)

    on_exit(fn ->
      send(TokenStore, :delete_all)
      :sys.get_state(TokenStore)
    end)

    # config = {
    #   base_url: base_url(bypass.port),
    #   client_id: "40skdjsakdjs",
    #   client_secret: "some secret"
    # }

    config = %Config{
      base_url: base_url(bypass.port),
      client_id: "some client id"
    }

    {:ok, bypass: bypass, user: user, config: config}
  end

  describe "reset_auth0_password/1" do
    test "successful reset", %{bypass: bypass, user: user, config: config} do
      Bypass.expect_once(bypass, "POST", "/dbconnections/change_password", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)

        payload = Jason.decode!(body)

        assert Map.fetch!(payload, "client_id") == config.client_id
        assert payload["connection"] == "Username-Password-Authentication"
        assert payload["email"] == user.email

        Plug.Conn.resp(conn, 200, "")
      end)

      assert HTTPClient.reset_auth0_password(user, config) == :ok
    end

    test "error if auth0 API down", %{bypass: bypass, user: user, config: config} do
      Bypass.down(bypass)

      fun = fn ->
        assert {:error, _} = HTTPClient.reset_auth0_password(user, config)
      end

      assert capture_log(fun) =~ "some error"
    end

    test "error if auth0 API returns anything but 200", %{
      bypass: bypass,
      user: user,
      config: config
    } do
      body = %{
        "error" => "Unauthorized",
        "message" => "Missing authentication"
      }

      Bypass.expect_once(bypass, "POST", "/dbconnections/change_password", fn conn ->
        Plug.Conn.resp(
          conn,
          401,
          Jason.encode!(body)
        )
      end)

      fun = fn ->
        assert {:error, _} = HTTPClient.reset_auth0_password(user, config)
      end

      assert capture_log(fun) =~ "some error"
    end
  end

  describe "verification_email/1" do
    test "successful verification email sent", %{bypass: bypass, user: user, config: config} do
      token = "abc1223"
      expect(Mock, :fetch_token, fn _ -> {:ok, %{access_token: token, expires_in: 3600}} end)

      Bypass.expect_once(bypass, "POST", "/api/v2/jobs/verification-email", fn conn ->
        {:ok, body, _conn} = Plug.Conn.read_body(conn)
        payload = Jason.decode!(body)

        assert Enum.any?(conn.req_headers, fn header ->
                 header == {"authorization", "Bearer #{token}"}
               end)

        assert Map.fetch!(payload, "client_id") == config.client_id
        assert payload["user_id"] == user.auth0_id

        Plug.Conn.resp(conn, 201, "")
      end)

      assert HTTPClient.resend_verification_email(user, config) == :ok
    end

    test "error if auth0 API down", %{bypass: bypass, user: user, config: config} do
      expect(Mock, :fetch_token, fn _ -> {:ok, %{access_token: "abc1223", expires_in: 3600}} end)
      Bypass.down(bypass)

      fun = fn ->
        assert {:error, _} = HTTPClient.resend_verification_email(user, config)
      end

      assert capture_log(fun) =~ "some error"
    end

    test "error if auth0 API returns anything but 201", %{
      bypass: bypass,
      user: user,
      config: config
    } do
      body = %{
        "error" => "Unauthorized",
        "message" => "Missing authentication"
      }

      expect(Mock, :fetch_token, fn _ -> {:ok, %{access_token: "abc1223", expires_in: 3600}} end)

      Bypass.expect_once(bypass, "POST", "/api/v2/jobs/verification-email", fn conn ->
        Plug.Conn.resp(
          conn,
          401,
          Jason.encode!(body)
        )
      end)

      fun = fn ->
        assert {:error, _} = HTTPClient.resend_verification_email(user, config)
      end

      assert capture_log(fun) =~ "some error"
    end
  end

  describe "fetch_user/1" do
    test "returns a user from auth0", %{bypass: bypass, user: user, config: config} do
      token = "abc123"
      expect(Mock, :fetch_token, fn _ -> {:ok, %{access_token: token, expires_in: 3600}} end)

      auth0_id =
        user.auth0_id
        |> URI.encode()
        |> String.downcase()

      Bypass.expect_once(bypass, "GET", "/api/v2/users/" <> auth0_id, fn conn ->
        assert Enum.any?(conn.req_headers, fn header ->
                 header == {"authorization", "Bearer #{token}"}
               end)

        Plug.Conn.resp(
          conn,
          200,
          Jason.encode!(@auth0_user_payload)
        )
      end)

      opts = Enum.map(@auth0_user_payload, fn {k, v} -> {String.to_atom(k), v} end)
      expected_user = struct(User, opts)

      assert HTTPClient.fetch_user(user, config) == {:ok, expected_user}
    end

    test "error auth0 api down", %{bypass: bypass, user: user, config: config} do
      expect(Mock, :fetch_token, fn _ -> {:ok, %{access_token: "INVALID", expires_in: 3600}} end)

      Bypass.down(bypass)

      fun = fn ->
        assert {:error, _} = HTTPClient.fetch_user(user, config)
      end

      assert capture_log(fun) =~ "some error"
    end

    test "auth0 api invalid token error", %{bypass: bypass, user: user, config: config} do
      expect(Mock, :fetch_token, fn _ -> {:ok, %{access_token: "INVALID", expires_in: 3600}} end)

      auth0_id =
        user.auth0_id
        |> URI.encode()
        |> String.downcase()

      body = %{
        "error" => "Unauthorized",
        "message" => "Missing authentication"
      }

      Bypass.expect_once(bypass, "GET", "/api/v2/users/" <> auth0_id, fn conn ->
        Plug.Conn.resp(
          conn,
          401,
          Jason.encode!(body)
        )
      end)

      fun = fn ->
        assert {:error, _} = HTTPClient.fetch_user(user, config)
      end

      assert capture_log(fun) =~ "some error"
    end

    test "missing required fields", %{bypass: bypass, user: user, config: config} do
      expect(Mock, :fetch_token, fn _ -> {:ok, %{access_token: "abc1223", expires_in: 3600}} end)

      auth0_id =
        user.auth0_id
        |> URI.encode()
        |> String.downcase()

      # invalid: missing required fields
      invalid_user_data = %{"email" => user.email}

      Bypass.expect_once(bypass, "GET", "/api/v2/users/" <> auth0_id, fn conn ->
        Plug.Conn.resp(
          conn,
          200,
          Jason.encode!(invalid_user_data)
        )
      end)

      fun = fn ->
        assert {:error, _} = HTTPClient.fetch_user(user, config)
      end

      assert capture_log(fun) =~ "Invalid data from Auth0 API"
    end

    test "email verified with invalid `email_verified` value", %{
      bypass: bypass,
      user: user,
      config: config
    } do
      expect(Mock, :fetch_token, fn _ -> {:ok, %{access_token: "abc1223", expires_in: 3600}} end)

      auth0_id =
        user.auth0_id
        |> URI.encode()
        |> String.downcase()

      invalid_user_data = %{
        "email" => user.email,
        "email_verified" => "invalid",
        "user_id" => "some user id"
      }

      Bypass.expect_once(bypass, "GET", "/api/v2/users/" <> auth0_id, fn conn ->
        Plug.Conn.resp(
          conn,
          200,
          Jason.encode!(invalid_user_data)
        )
      end)

      fun = fn ->
        assert {:error, _} = HTTPClient.fetch_user(user, config)
      end

      assert capture_log(fun) =~ "Invalid data from Auth0 API"
    end
  end

  describe "fetch_token/0" do
    test "successful token fetching", %{bypass: bypass, config: config} do
      body = %{access_token: "REDACTED", expires_in: 3600}

      Bypass.expect_once(bypass, "POST", "/oauth/token", fn conn ->
        Plug.Conn.resp(
          conn,
          200,
          Jason.encode!(body)
        )
      end)

      {:ok, response} = HTTPClient.fetch_token(config)

      assert response == body
    end

    test "unsuccessful token fetching", %{bypass: bypass, config: config} do
      body = %{error: "access_denied", error_desciption: "Unauthorized"}

      Bypass.expect_once(bypass, "POST", "/oauth/token", fn conn ->
        Plug.Conn.resp(
          conn,
          401,
          Jason.encode!(body)
        )
      end)

      fun = fn ->
        assert {:error, _} = HTTPClient.fetch_token(config)
      end

      assert capture_log(fun) =~ "some error"
    end

    test "auth0 service down", %{bypass: bypass, config: config} do
      Bypass.down(bypass)

      fun = fn ->
        assert {:error, _} = HTTPClient.fetch_token(config)
      end

      assert capture_log(fun) =~ "some error"
    end
  end

  describe "users_by_email/1" do
    test "finds user by email", %{bypass: bypass, user: %{email: email}, config: config} do
      expect(Mock, :fetch_token, fn _ -> {:ok, %{access_token: "abc1223", expires_in: 3600}} end)

      path = "/api/v2/users-by-email"

      Bypass.expect_once(bypass, "GET", path, fn conn ->
        %{query_params: query_params} = Plug.Conn.fetch_query_params(conn)

        assert %{"email" => ^email} = query_params

        Plug.Conn.resp(
          conn,
          200,
          Jason.encode!([@auth0_user_payload])
        )
      end)

      opts = Enum.map(@auth0_user_payload, fn {k, v} -> {String.to_atom(k), v} end)
      expected_users = [struct(User, opts)]

      assert HTTPClient.users_by_email(email, config) == {:ok, expected_users}
    end

    test "error if auth0 API down", %{bypass: bypass, user: %{email: email}, config: config} do
      expect(Mock, :fetch_token, fn _ -> {:ok, %{access_token: "abc1223", expires_in: 3600}} end)

      Bypass.down(bypass)

      fun = fn ->
        assert {:error, _} = HTTPClient.users_by_email(email, config)
      end

      assert capture_log(fun) =~ "some error"
    end

    test "ignores invalid user data and logs error", %{
      bypass: bypass,
      user: %{email: email},
      config: config
    } do
      expect(Mock, :fetch_token, fn _ -> {:ok, %{access_token: "abc1223", expires_in: 3600}} end)

      path = "/api/v2/users-by-email"

      # invalid because it's missing `email_verified`
      invalid_user = %{
        "email" => "jon@doe.com",
        "user_id" => "auth0|1234"
      }

      Bypass.expect_once(bypass, "GET", path, fn conn ->
        Plug.Conn.resp(
          conn,
          200,
          Jason.encode!([invalid_user])
        )
      end)

      fun = fn ->
        assert {:ok, []} = HTTPClient.users_by_email(email, config)
      end

      assert capture_log(fun) =~ "Invalid data from Auth0"
    end
  end

  describe "unblock_user/1" do
    test "unlock a blocked auth0 user", %{bypass: bypass, user: user, config: config} do
      expect(Mock, :fetch_token, fn _ -> {:ok, %{access_token: "token", expires_in: 3600}} end)

      Bypass.expect_once(
        bypass,
        "DELETE",
        "/api/v2/user-blocks/#{URI.encode(user.auth0_id)}",
        fn conn ->
          Plug.Conn.resp(conn, 204, "")
        end
      )

      assert HTTPClient.unblock_user(user, config) == :ok
    end

    test "attempt to unblock an auth0 user that doesn't exist", %{
      bypass: bypass,
      user: user,
      config: config
    } do
      expect(Mock, :fetch_token, fn _ -> {:ok, %{access_token: "token", expires_in: 3600}} end)

      Bypass.expect_once(
        bypass,
        "DELETE",
        "/api/v2/user-blocks/#{URI.encode(user.auth0_id)}",
        fn conn ->
          Plug.Conn.resp(conn, 404, "")
        end
      )

      fun = fn ->
        assert {:error, _} = HTTPClient.unblock_user(user, config)
      end

      assert capture_log(fun) =~ "Unblock User failed"
    end

    test "auth0 service down", %{bypass: bypass, user: user, config: config} do
      expect(Mock, :fetch_token, fn _ -> {:ok, %{access_token: "token", expires_in: 3600}} end)

      Bypass.down(bypass)

      fun = fn ->
        assert {:error, _} = HTTPClient.unblock_user(user, config)
      end

      assert capture_log(fun) =~ "Unblock User failed"
    end
  end

  defp base_url(port), do: "http://localhost:#{port}"
end
