defmodule Engine.VMDTest do
  use Engine.DataCase

  alias Engine.VMD

  describe "vehicle_definitions" do
    alias Engine.VMD.VehicleDefinition

    @valid_attrs %{make: "some make", model: "some model", year: 42}
    @update_attrs %{make: "some updated make", model: "some updated model", year: 43}
    @invalid_attrs %{make: nil, model: nil, year: nil}

    def vehicle_definition_fixture(attrs \\ %{}) do
      {:ok, vehicle_definition} =
        attrs
        |> Enum.into(@valid_attrs)
        |> VMD.create_vehicle_definition()

      vehicle_definition
    end

    test "list_vehicle_definitions/0 returns all vehicle_definitions" do
      vehicle_definition = vehicle_definition_fixture()
      assert VMD.list_vehicle_definitions() == [vehicle_definition]
    end

    test "get_vehicle_definition!/1 returns the vehicle_definition with given id" do
      vehicle_definition = vehicle_definition_fixture()
      assert VMD.get_vehicle_definition!(vehicle_definition.id) == vehicle_definition
    end

    test "create_vehicle_definition/1 with valid data creates a vehicle_definition" do
      assert {:ok, %VehicleDefinition{} = vehicle_definition} = VMD.create_vehicle_definition(@valid_attrs)
      assert vehicle_definition.make == "some make"
      assert vehicle_definition.model == "some model"
      assert vehicle_definition.year == 42
    end

    test "create_vehicle_definition/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = VMD.create_vehicle_definition(@invalid_attrs)
    end

    test "update_vehicle_definition/2 with valid data updates the vehicle_definition" do
      vehicle_definition = vehicle_definition_fixture()
      assert {:ok, %VehicleDefinition{} = vehicle_definition} = VMD.update_vehicle_definition(vehicle_definition, @update_attrs)
      assert vehicle_definition.make == "some updated make"
      assert vehicle_definition.model == "some updated model"
      assert vehicle_definition.year == 43
    end

    test "update_vehicle_definition/2 with invalid data returns error changeset" do
      vehicle_definition = vehicle_definition_fixture()
      assert {:error, %Ecto.Changeset{}} = VMD.update_vehicle_definition(vehicle_definition, @invalid_attrs)
      assert vehicle_definition == VMD.get_vehicle_definition!(vehicle_definition.id)
    end

    test "delete_vehicle_definition/1 deletes the vehicle_definition" do
      vehicle_definition = vehicle_definition_fixture()
      assert {:ok, %VehicleDefinition{}} = VMD.delete_vehicle_definition(vehicle_definition)
      assert_raise Ecto.NoResultsError, fn -> VMD.get_vehicle_definition!(vehicle_definition.id) end
    end

    test "change_vehicle_definition/1 returns a vehicle_definition changeset" do
      vehicle_definition = vehicle_definition_fixture()
      assert %Ecto.Changeset{} = VMD.change_vehicle_definition(vehicle_definition)
    end
  end

  describe "vehicles" do
    alias Engine.VMD.Vehicle

    @valid_attrs %{vin: "some vin"}
    @update_attrs %{vin: "some updated vin"}
    @invalid_attrs %{vin: nil}

    def vehicle_fixture(attrs \\ %{}) do
      {:ok, vehicle} =
        attrs
        |> Enum.into(@valid_attrs)
        |> VMD.create_vehicle()

      vehicle
    end

    test "list_vehicles/0 returns all vehicles" do
      vehicle = vehicle_fixture()
      assert VMD.list_vehicles() == [vehicle]
    end

    test "get_vehicle!/1 returns the vehicle with given id" do
      vehicle = vehicle_fixture()
      assert VMD.get_vehicle!(vehicle.id) == vehicle
    end

    test "create_vehicle/1 with valid data creates a vehicle" do
      assert {:ok, %Vehicle{} = vehicle} = VMD.create_vehicle(@valid_attrs)
      assert vehicle.vin == "some vin"
    end

    test "create_vehicle/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = VMD.create_vehicle(@invalid_attrs)
    end

    test "update_vehicle/2 with valid data updates the vehicle" do
      vehicle = vehicle_fixture()
      assert {:ok, %Vehicle{} = vehicle} = VMD.update_vehicle(vehicle, @update_attrs)
      assert vehicle.vin == "some updated vin"
    end

    test "update_vehicle/2 with invalid data returns error changeset" do
      vehicle = vehicle_fixture()
      assert {:error, %Ecto.Changeset{}} = VMD.update_vehicle(vehicle, @invalid_attrs)
      assert vehicle == VMD.get_vehicle!(vehicle.id)
    end

    test "delete_vehicle/1 deletes the vehicle" do
      vehicle = vehicle_fixture()
      assert {:ok, %Vehicle{}} = VMD.delete_vehicle(vehicle)
      assert_raise Ecto.NoResultsError, fn -> VMD.get_vehicle!(vehicle.id) end
    end

    test "change_vehicle/1 returns a vehicle changeset" do
      vehicle = vehicle_fixture()
      assert %Ecto.Changeset{} = VMD.change_vehicle(vehicle)
    end
  end
end
