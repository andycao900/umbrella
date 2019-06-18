defmodule Authentication.UserFromAuth do
  @moduledoc """
  Retrieve the user information from an auth request
  """
  require Logger

  alias Engine.Accounts
  alias Engine.Accounts.User
  alias Ueberauth.Auth

  @doc """
  Finds or creates a new :internal or :consumer user based on an Auth0 response.
  :internal - Admin user - AdminWeb
  :consumer - Consumer user - CarsWeb
  If a user is found, the user's last sign in date is updated.

  For an example of usage see `AdminWeb.AuthController`
  """
  @spec find_or_create(Auth.t(), :internal | :consumer) ::
          {:ok, %User{}} | {:error, %Ecto.Changeset{}}
  def find_or_create(%Auth{} = auth, type) when type in [:internal, :consumer] do
    prepared_user =
      auth
      |> parse_auth0_response()
      |> Map.put(:last_signed_in_at, DateTime.utc_now())
      |> set_type(type)
      |> IO.inspect()

    case Accounts.get_user_by_auth0_id(prepared_user.auth0_id) do
      nil ->
        Accounts.create_user(prepared_user)

      %User{} = user ->
        Accounts.update_user(user, %{last_signed_in_at: DateTime.utc_now()})
    end
  end

  def find_or_create(_, type) when type in [:internal, :consumer] do
    error_string = "Login Failure. No auth0 response struct provided."
    :ok = Logger.error(fn -> error_string end)
    {:error, error_string}
  end

  defp avatar_from_auth(%{info: %{image: image}}), do: image

  defp parse_auth0_response(auth) do
    %{
      auth0_id: auth.uid,
      name: name_from_auth(auth),
      avatar_url: avatar_from_auth(auth),
      email: auth.info.email
    }
  end

  defp name_from_auth(%{info: info} = _auth) do
    email = info.email

    case get_names_from_info(info) do
      %{name: "", first_name: "", last_name: ""} ->
        info.nickname

      %{name: "", first_name: first_name, last_name: ""} ->
        first_name

      %{name: "", first_name: "", last_name: last_name} ->
        last_name

      %{name: "", first_name: first_name, last_name: last_name} ->
        "#{first_name} #{last_name}"

      %{name: name} when name == email ->
        nil

      %{name: name} ->
        name
    end
  end

  defp get_names_from_info(info) do
    info
    |> Map.take([:nickname, :name, :first_name, :last_name])
    |> Enum.into(%{}, &nil_value_to_string/1)
  end

  defp nil_value_to_string({key, nil}), do: {key, ""}
  defp nil_value_to_string(pair), do: pair

  defp set_type(auth, :internal), do: auth |> Map.put(:type, "internal") |> put_email_verified()
  defp set_type(auth, :consumer), do: auth |> Map.put(:type, "consumer")

  defp put_email_verified(%{auth0_id: "adfs" <> _} = user) do
    Map.put(user, :email_verified, true)
  end

  defp put_email_verified(user), do: user
end
