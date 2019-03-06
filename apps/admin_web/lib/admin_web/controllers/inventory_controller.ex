defmodule AdminWeb.InventoryController do
  use AdminWeb, :controller

  alias Engine.InventoryTracker
  alias Engine.InventoryTracker.Inventory

  def index(conn, _params) do
    inventories = InventoryTracker.list_inventories()
    render(conn, "index.html", inventories: inventories)
  end

  def new(conn, _params) do
    changeset = InventoryTracker.change_inventory(%Inventory{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"inventory" => inventory_params}) do
    case InventoryTracker.create_inventory(inventory_params) do
      {:ok, inventory} ->
        conn
        |> put_flash(:info, "Inventory created successfully.")
        |> redirect(to: Routes.inventory_path(conn, :show, inventory))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    inventory = InventoryTracker.get_inventory!(id)
    render(conn, "show.html", inventory: inventory)
  end

  def edit(conn, %{"id" => id}) do
    inventory = InventoryTracker.get_inventory!(id)
    changeset = InventoryTracker.change_inventory(inventory)
    render(conn, "edit.html", inventory: inventory, changeset: changeset)
  end

  def update(conn, %{"id" => id, "inventory" => inventory_params}) do
    inventory = InventoryTracker.get_inventory!(id)

    case InventoryTracker.update_inventory(inventory, inventory_params) do
      {:ok, inventory} ->
        conn
        |> put_flash(:info, "Inventory updated successfully.")
        |> redirect(to: Routes.inventory_path(conn, :show, inventory))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", inventory: inventory, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    inventory = InventoryTracker.get_inventory!(id)
    {:ok, _inventory} = InventoryTracker.delete_inventory(inventory)

    conn
    |> put_flash(:info, "Inventory deleted successfully.")
    |> redirect(to: Routes.inventory_path(conn, :index))
  end
end
