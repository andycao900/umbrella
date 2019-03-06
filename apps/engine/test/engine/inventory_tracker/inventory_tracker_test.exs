defmodule Engine.InventoryTrackerTest do
  use Engine.DataCase

  alias Engine.InventoryTracker

  describe "inventories" do
    alias Engine.InventoryTracker.Inventory

    @valid_attrs %{dealer_id: "some dealer_id"}
    @update_attrs %{dealer_id: "some updated dealer_id"}
    @invalid_attrs %{dealer_id: nil}

    def inventory_fixture(attrs \\ %{}) do
      {:ok, inventory} =
        attrs
        |> Enum.into(@valid_attrs)
        |> InventoryTracker.create_inventory()

      inventory
    end

    test "list_inventories/0 returns all inventories" do
      inventory = inventory_fixture()
      assert InventoryTracker.list_inventories() == [inventory]
    end

    test "get_inventory!/1 returns the inventory with given id" do
      inventory = inventory_fixture()
      assert InventoryTracker.get_inventory!(inventory.id) == inventory
    end

    test "create_inventory/1 with valid data creates a inventory" do
      assert {:ok, %Inventory{} = inventory} = InventoryTracker.create_inventory(@valid_attrs)
      assert inventory.dealer_id == "some dealer_id"
    end

    test "create_inventory/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = InventoryTracker.create_inventory(@invalid_attrs)
    end

    test "update_inventory/2 with valid data updates the inventory" do
      inventory = inventory_fixture()
      assert {:ok, %Inventory{} = inventory} = InventoryTracker.update_inventory(inventory, @update_attrs)
      assert inventory.dealer_id == "some updated dealer_id"
    end

    test "update_inventory/2 with invalid data returns error changeset" do
      inventory = inventory_fixture()
      assert {:error, %Ecto.Changeset{}} = InventoryTracker.update_inventory(inventory, @invalid_attrs)
      assert inventory == InventoryTracker.get_inventory!(inventory.id)
    end

    test "delete_inventory/1 deletes the inventory" do
      inventory = inventory_fixture()
      assert {:ok, %Inventory{}} = InventoryTracker.delete_inventory(inventory)
      assert_raise Ecto.NoResultsError, fn -> InventoryTracker.get_inventory!(inventory.id) end
    end

    test "change_inventory/1 returns a inventory changeset" do
      inventory = inventory_fixture()
      assert %Ecto.Changeset{} = InventoryTracker.change_inventory(inventory)
    end
  end
end
