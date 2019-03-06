defmodule AdminWeb.VehicleControllerTest do
  use AdminWeb.ConnCase

  alias Engine.VMD

  @create_attrs %{vin: "some vin"}
  @update_attrs %{vin: "some updated vin"}
  @invalid_attrs %{vin: nil}

  def fixture(:vehicle) do
    {:ok, vehicle} = VMD.create_vehicle(@create_attrs)
    vehicle
  end

  describe "index" do
    test "lists all vehicles", %{conn: conn} do
      conn = get(conn, Routes.vehicle_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Vehicles"
    end
  end

  describe "new vehicle" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.vehicle_path(conn, :new))
      assert html_response(conn, 200) =~ "New Vehicle"
    end
  end

  describe "create vehicle" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.vehicle_path(conn, :create), vehicle: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.vehicle_path(conn, :show, id)

      conn = get(conn, Routes.vehicle_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Vehicle"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.vehicle_path(conn, :create), vehicle: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Vehicle"
    end
  end

  describe "edit vehicle" do
    setup [:create_vehicle]

    test "renders form for editing chosen vehicle", %{conn: conn, vehicle: vehicle} do
      conn = get(conn, Routes.vehicle_path(conn, :edit, vehicle))
      assert html_response(conn, 200) =~ "Edit Vehicle"
    end
  end

  describe "update vehicle" do
    setup [:create_vehicle]

    test "redirects when data is valid", %{conn: conn, vehicle: vehicle} do
      conn = put(conn, Routes.vehicle_path(conn, :update, vehicle), vehicle: @update_attrs)
      assert redirected_to(conn) == Routes.vehicle_path(conn, :show, vehicle)

      conn = get(conn, Routes.vehicle_path(conn, :show, vehicle))
      assert html_response(conn, 200) =~ "some updated vin"
    end

    test "renders errors when data is invalid", %{conn: conn, vehicle: vehicle} do
      conn = put(conn, Routes.vehicle_path(conn, :update, vehicle), vehicle: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Vehicle"
    end
  end

  describe "delete vehicle" do
    setup [:create_vehicle]

    test "deletes chosen vehicle", %{conn: conn, vehicle: vehicle} do
      conn = delete(conn, Routes.vehicle_path(conn, :delete, vehicle))
      assert redirected_to(conn) == Routes.vehicle_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.vehicle_path(conn, :show, vehicle))
      end
    end
  end

  defp create_vehicle(_) do
    vehicle = fixture(:vehicle)
    {:ok, vehicle: vehicle}
  end
end
