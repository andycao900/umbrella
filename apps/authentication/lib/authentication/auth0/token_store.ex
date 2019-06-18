defmodule Authentication.Auth0.TokenStore do
  @moduledoc """
  Fetches [Auth0 API](https://auth0.com/docs/api/info) access token and stores
  it in [ETS](http://erlang.org/doc/man/ets.html).

  Renews token before expiration.

  While a process and ETS table name can be passed at start, this functionality is
  intended to be limited to testing only. Using a custom name will cause unxpected
  behavior in any environment other than test.
  """

  use GenServer

  require Logger

  alias Authentication.Auth0.Config
  alias Authentication.Auth0.Token

  @table :auth0_management_api_tokens

  @default_opts [
    table_name: @table,
    name: __MODULE__
  ]

  # Client

  def start_link(opts) do
    composed_opts = Keyword.merge(@default_opts, opts)
    GenServer.start_link(__MODULE__, composed_opts, name: composed_opts[:name])
  end

  @doc """
  Fetches a `t:Token.t/0` from ETS table.

  If there is no token in ETS table:
  - fetches new token from Auth0 API
  - saves new token in table
  - schedules table flush (to ensure fresh tokens)
  - returns new token

  """

  @spec fetch_token(module(), Config.t()) :: {:ok, Token.t()} | {:error, String.t()}
  def fetch_token(auth0_api, %{otp_app: otp_app} = config \\ %Config{}) do
    return_or_insert_token(:ets.lookup(@table, otp_app), auth0_api, config)
  end

  defp return_or_insert_token([{_, token} | _tail], _auth0_api, _config) do
    {:ok, token}
  end

  defp return_or_insert_token([], auth0_api, config) do
    case GenServer.call(__MODULE__, {:fetch_and_insert_token, auth0_api, config}) do
      {:ok, token} ->
        {:ok, token}

      _ ->
        :ok = Logger.error(fn -> "Error fetching token in #{inspect(__MODULE__)}" end)
        {:error, "error fetching Auth0 API token"}
    end
  end

  @doc false
  def table_name, do: @table

  # Server (callbacks)

  @impl true
  def init(opts) do
    _ = :ets.new(opts[:table_name], [:set, :named_table, :protected, read_concurrency: true])

    {:ok, %{}}
  end

  @impl true
  def handle_call(
        {:fetch_and_insert_token, auth0_api, %{otp_app: otp_app} = config},
        _from,
        state
      ) do
    response =
      with [] <- :ets.lookup(@table, otp_app), {:ok, token} <- auth0_api.fetch_token(config) do
        :ets.insert(@table, {otp_app, token})
        schedule_delete(otp_app, token)

        {:ok, token}
      else
        [{_, token} | _tail] ->
          {:ok, token}

        _ ->
          :ok = Logger.error(fn -> "Error fetching token in #{inspect(__MODULE__)}" end)
          {:error, "error fetching Auth0 API token"}
      end

    {:reply, response, state}
  end

  @impl true
  def handle_call({:insert, {token, %{otp_app: otp_app} = config}}, _from, state)
      when not is_nil(otp_app) do
    :ets.insert(@table, {config.otp_app, token})

    {:reply, :ok, state}
  end

  @impl true
  def handle_info({:delete, otp_app}, state) do
    :ets.delete(@table, otp_app)

    {:noreply, state}
  end

  @impl true
  def handle_info(:delete_all, state) do
    :ets.delete_all_objects(@table)

    {:noreply, state}
  end

  # Private

  defp schedule_delete(otp_app, token) do
    delete_in = :timer.seconds(token.expires_in - 10)
    Process.send_after(__MODULE__, {:delete, otp_app}, delete_in)
  end
end
