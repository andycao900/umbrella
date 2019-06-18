defmodule AdminWeb.Plug.RequireADFSAuthorization do
  @moduledoc """
  Authorization plug for redirecting unauthenticated traffic to login page.

  Expects `current_user` to be set in assigns and for it to have `adfs_groups`
  preloaded.
  """

  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]

  alias AdminWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  @doc """
  No-op if user belongs to given ADFS group, otherwise redirects to `AdminWeb`'s home page.
  """
  def call(%{assigns: %{current_user: user}} = conn, authorized_group_names)
      when is_list(authorized_group_names) do
    # Add `:team_beta` group authorization by default
    if authorized?(user, [:team_beta | authorized_group_names]) do
      conn
    else
      conn
      |> put_flash(:error, "You aren't authorized to view this page.")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  defp authorized?(%{adfs_groups: adfs_groups} = _user, authorized_group_names) do
    adfs_group_ids = names_to_ids(authorized_group_names)
    Enum.any?(adfs_groups, &(&1.remote_adfs_group_id in adfs_group_ids))
  end

  defp names_to_ids(authorized_group_names) do
    Enum.map(authorized_group_names, fn authorized_group ->
      Map.fetch!(adfs_groups(), authorized_group)
    end)
  end

  defp adfs_groups do
    Application.get_env(:admin_web, :adfs_groups)
  end
end
