defmodule Authentication.Auth0.TokenStoreTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog
  import Mox

  alias Authentication.Auth0.Config
  alias Authentication.Auth0.Mock, as: Auth0Mock
  alias Authentication.Auth0.TokenStore

  # Make sure Auth0Mocks are verified when the test exits
  setup :verify_on_exit!
  setup :set_mox_global

  setup do
    otp_app = :some_app

    on_exit(fn ->
      send(TokenStore, :delete_all)

      # this call will block until the TokenStore's mailbox is empty
      :sys.get_state(TokenStore)
    end)

    {:ok, otp_app: otp_app}
  end

  describe "fetch_token/1" do
    test "success", %{otp_app: otp_app} do
      token = %{
        access_token: "some token",
        expires_in: 3_600
      }

      config = %Config{otp_app: otp_app}
      expect(Auth0Mock, :fetch_token, fn _ -> {:ok, token} end)

      {:ok, returned_token1} = TokenStore.fetch_token(Auth0Mock, config)

      assert returned_token1 == token

      [{^otp_app, returned_token2} | _] = :ets.lookup(TokenStore.table_name(), otp_app)

      assert returned_token2 == token

      # ensure it knows how to get token from ETS
      {:ok, returned_token3} = TokenStore.fetch_token(Auth0Mock, config)

      assert returned_token3 == token
    end

    test "with tokens for multiple apps", %{otp_app: otp_app1} do
      otp_app2 = :some_other_app

      token1 = %{
        access_token: "some token",
        expires_in: 3_600
      }

      token2 = %{
        access_token: "some other token",
        expires_in: 3_600
      }

      config1 = %Config{otp_app: otp_app1}
      config2 = %Config{otp_app: otp_app2}

      expect(Auth0Mock, :fetch_token, fn ^config1 -> {:ok, token1} end)
      expect(Auth0Mock, :fetch_token, fn ^config2 -> {:ok, token2} end)

      assert {:ok, ^token1} = TokenStore.fetch_token(Auth0Mock, config1)
      assert [{^otp_app1, ^token1} | _] = :ets.lookup(TokenStore.table_name(), otp_app1)
      assert {:ok, ^token1} = TokenStore.fetch_token(Auth0Mock, config1)

      assert {:ok, ^token2} = TokenStore.fetch_token(Auth0Mock, config2)
      assert [{^otp_app2, ^token2} | _] = :ets.lookup(TokenStore.table_name(), otp_app2)
      assert {:ok, ^token2} = TokenStore.fetch_token(Auth0Mock, config2)
    end

    test "with error fetching token from Auth0", %{otp_app: otp_app} do
      expect(Auth0Mock, :fetch_token, fn _ -> {:error, "some error"} end)

      config = %Config{otp_app: otp_app}

      fun = fn ->
        assert {:error, _} = TokenStore.fetch_token(Auth0Mock, config)
      end

      assert capture_log(fun) =~ "Error fetching token"
    end

    test "ensure no race condition for token fetching", %{otp_app: otp_app} do
      config = %Config{otp_app: otp_app}

      token1 = %{
        access_token: "token one",
        expires_in: 3_600
      }

      token2 = %{
        access_token: "token two",
        expires_in: 3_600
      }

      expect(Auth0Mock, :fetch_token, fn _ -> {:ok, token1} end)

      stub(Auth0Mock, :fetch_token, fn _ -> {:ok, token2} end)

      task1 = Task.async(fn -> TokenStore.fetch_token(Auth0Mock, config) end)

      task2 = Task.async(fn -> TokenStore.fetch_token(Auth0Mock, config) end)

      assert {:ok, token1} == Task.await(task2)
      refute {:ok, token2} == Task.await(task1)
    end
  end

  describe "handle_call/3 :insert" do
    test "inserts token", %{otp_app: otp_app} do
      token = "some token"
      config = %Config{otp_app: otp_app}

      :ok = GenServer.call(TokenStore, {:insert, {token, config}})

      assert [{otp_app, ^token} | _] = :ets.lookup(TokenStore.table_name(), config.otp_app)
    end

    test "raises when `otp_app` is nil" do
      token = "some token"
      config = %Config{otp_app: nil}

      assert_raise FunctionClauseError, fn ->
        TokenStore.handle_call({:insert, {token, config}}, "from", %{})
      end
    end
  end

  describe "handle_info/2 :delete" do
    test "deletes all objects for otp_app from ETS table", %{otp_app: otp_app} do
      token = "some token"
      config = %Config{otp_app: otp_app}
      GenServer.call(TokenStore, {:insert, {token, config}})

      assert [{^otp_app, ^token} | _] = :ets.lookup(TokenStore.table_name(), config.otp_app)

      send(TokenStore, {:delete, otp_app})

      :sys.get_state(TokenStore)

      assert :ets.lookup(TokenStore.table_name(), otp_app) == []
    end
  end

  describe "start_link & init" do
    test "creates an ets table", setup do
      test_opts = [
        name: setup.test,
        table_name: :token_store_test_table
      ]

      {:ok, pid} = start_supervised({TokenStore, test_opts})
      refute :undefined == :ets.whereis(test_opts[:table_name])
      assert Process.info(pid)[:registered_name] == test_opts[:name]
    end
  end
end
