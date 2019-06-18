defmodule Authentication.Plug.FetchUserFromSession do
  @moduledoc """
  Sets the current user from current_user_id if present in session storage. Takes a
  resolver function that turns a user_id into a User.

  Usage:

  ```
      pipeline :my_pipeline do
        plug FetchUserFromSession, user_resolver: &Engine.Accounts.get_user/1
      end
  ```
  """
  import Plug.Conn, only: [get_session: 2, assign: 3]

  def init(opts \\ []) do
    case Keyword.get(opts, :user_resolver) do
      nil -> raise "#{inspect(__MODULE__)} missing user_resolver opt"
      user_resolver -> %{user_resolver: user_resolver}
    end
  end

  def call(conn, %{user_resolver: user_resolver}) do
    current_user =
      conn
      |> get_session(:current_user_id)
      |> get_current_user(user_resolver)

    assign(conn, :current_user, current_user)
  end

  defp get_current_user(nil, _), do: nil

  defp get_current_user(current_user_id, user_resolver) do
    user_resolver.(current_user_id)
  end
end
