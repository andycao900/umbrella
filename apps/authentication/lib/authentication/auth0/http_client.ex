defmodule Authentication.Auth0.HTTPClient do
  @moduledoc """
  Invoke for various API requests made to Auth0.
  """
  require Logger

  alias Authentication.Auth0
  alias Authentication.Auth0.Config
  alias Authentication.Auth0.User, as: Auth0User
  alias Engine.Accounts.User

  @behaviour Authentication.Auth0.Behaviour

  @doc """
  Calls Auth0 API to request a password reset email for a given user
  """
  @impl true
  def reset_auth0_password(%User{email: email}, %Config{base_url: base_url, client_id: client_id}) do
    password_reset_url = password_reset_url(base_url)
    header_list = %{"Content-Type" => "application/json"}

    password_reset_payload =
      Jason.encode!(%{
        client_id: client_id,
        email: email,
        connection: "Username-Password-Authentication"
      })

    case HTTPoison.post(password_reset_url, password_reset_payload, header_list) do
      {:ok, %{status_code: 200}} ->
        :ok

      {_, reason} ->
        :ok = Logger.error(fn -> "some error with #{inspect(reason)}" end)
        {:error, "Error from Auth0 API"}
    end
  end

  @doc """
  Calls Auth0 API to request a verification email for a given user
  """
  @impl true
  def resend_verification_email(
        %User{auth0_id: auth0_id},
        %Config{
          base_url: base_url,
          client_id: client_id
        } = config
      ) do
    payload =
      Jason.encode!(%{
        user_id: auth0_id,
        client_id: client_id
      })

    with {:ok, %{access_token: token}} <- Auth0.fetch_token(config),
         {:ok, %{status_code: 201}} <-
           HTTPoison.post(verification_email_url(base_url), payload, headers(token)) do
      :ok
    else
      {_, reason} ->
        :ok = Logger.error(fn -> "some error with #{inspect(reason)}" end)
        {:error, "Error from Auth0 API"}
    end
  end

  @doc """
  Calls Auth0 api to obtain a token that is required to interact with Auth0 management API
  """
  @impl true
  def fetch_token(%Config{base_url: base_url, client_id: client_id, client_secret: client_secret}) do
    auth0_token_url = token_url(base_url)
    header_list = %{"Content-Type" => "application/json"}

    payload =
      Jason.encode!(%{
        audience: audience_url(base_url),
        client_id: client_id,
        client_secret: client_secret,
        grant_type: "client_credentials"
      })

    case HTTPoison.post(auth0_token_url, payload, header_list) do
      {:ok, %{status_code: 200} = response} ->
        {:ok, parse_token_response(response)}

      {_, reason} ->
        :ok = Logger.error(fn -> "some error with #{inspect(reason)}" end)
        {:error, "Error from Auth0 Token API"}
    end
  end

  @doc """
  Requests user information from Auth0 Management API
  """
  @impl true
  def fetch_user(%User{auth0_id: auth0_id}, %Config{base_url: base_url} = config) do
    auth0_url = user_url(auth0_id, base_url)

    {:ok, %{access_token: token}} = Auth0.fetch_token(config)
    header_list = %{"Content-Type" => "application/json", "Authorization" => "Bearer #{token}"}

    case HTTPoison.get(auth0_url, header_list) do
      {:ok, %{status_code: 200} = response} ->
        response.body
        |> Jason.decode!()
        |> validate_auth0_user()

      {_, reason} ->
        :ok = Logger.error(fn -> "some error with #{inspect(reason)}" end)
        {:error, "Error from Auth0 User API"}
    end
  end

  @doc """
  Search users by email.

  For detials on the Auth0 API endpoint used please see:
  https://auth0.com/docs/api/management/v2/#!/Users_By_Email/get_users_by_email
  """
  @impl true
  def users_by_email(email, %Config{base_url: base_url} = config) do
    auth0_url = users_by_email_url(email, base_url)

    {:ok, %{access_token: token}} = Auth0.fetch_token(config)

    header_list = %{
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{token}"
    }

    case HTTPoison.get(auth0_url, header_list) do
      {:ok, %{status_code: 200} = response} ->
        response.body
        |> Jason.decode!()
        |> validate_auth0_users()

      {_, reason} ->
        :ok = Logger.error(fn -> "some error with #{inspect(reason)}" end)
        {:error, "Error from Auth0 User API"}
    end
  end

  @doc """
  Calls Auth0 to remove an Auth0 block status if user is blocked from brute-force attempt
  """
  @impl true
  def unblock_user(%User{auth0_id: auth0_id}, %Config{base_url: base_url} = config) do
    with {:ok, %{access_token: token}} <- Auth0.fetch_token(config),
         {:ok, %{status_code: 204}} <-
           HTTPoison.delete(unblock_user_url(auth0_id, base_url), headers(token)) do
      :ok
    else
      {_, reason} ->
        :ok = Logger.error(fn -> "Unblock User failed with error from #{inspect(reason)}" end)
        {:error, "Error from Auth0 API: #{inspect(reason)}"}
    end
  end

  defp validate_auth0_user(response_body) do
    case Auth0User.validate(response_body) do
      {:error, changeset} = error ->
        :ok = Logger.error(fn -> "Invalid data from Auth0 API #{inspect(changeset)}" end)
        error

      {:ok, _user} = result ->
        result
    end
  end

  defp validate_auth0_users(response_body) do
    auth0_users =
      Enum.reduce(response_body, [], fn user, validated_users ->
        case validate_auth0_user(user) do
          {:ok, validated_user} -> [validated_user | validated_users]
          {:error, _} -> validated_users
        end
      end)

    {:ok, auth0_users}
  end

  defp parse_token_response(%{body: body}) do
    body
    |> Jason.decode!()
    |> Map.take(["access_token", "expires_in"])
    |> Enum.into(%{}, fn {key, value} -> {String.to_atom(key), value} end)
  end

  defp headers(token) do
    %{"Content-Type" => "application/json", "Authorization" => "Bearer #{token}"}
  end

  defp token_url(base_url) do
    "#{base_url}/oauth/token"
  end

  defp user_url(auth0_id, base_url) do
    "#{base_url}/api/v2/users/#{auth0_id}"
  end

  defp audience_url(base_url) do
    "#{base_url}/api/v2/"
  end

  defp password_reset_url(base_url) do
    "#{base_url}/dbconnections/change_password"
  end

  defp users_by_email_url(email, base_url) do
    "#{base_url}/api/v2/users-by-email?email=#{email}"
  end

  defp verification_email_url(base_url) do
    "#{base_url}/api/v2/jobs/verification-email"
  end

  defp unblock_user_url(auth0_id, base_url) do
    "#{base_url}/api/v2/user-blocks/#{URI.encode(auth0_id)}"
  end
end
