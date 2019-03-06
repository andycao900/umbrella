defmodule AdminWeb.VehicleDefinitionControllerTest do
  use AdminWeb.ConnCase

  alias Engine.VMD

  @create_attrs %{make: "some make", model: "some model", year: 42}
  @update_attrs %{make: "some updated make", model: "some updated model", year: 43}
  @invalid_attrs %{make: nil, model: nil, year: nil}

  def fixture(:vehicle_definition) do
    {:ok, vehicle_definition} = VMD.create_vehicle_definition(@create_attrs)
    vehicle_definition
  end

  describe "index" do
    test "lists all vehicle_definitions", %{conn: conn} do
      conn = get(conn, Routes.vehicle_definition_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Vehicle definitions"
    end
  end

  describe "new vehicle_definition" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.vehicle_definition_path(conn, :new))
      assert html_response(conn, 200) =~ "New Vehicle definition"
    end
  end

  describe "create vehicle_definition" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.vehicle_definition_path(conn, :create), vehicle_definition: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.vehicle_definition_path(conn, :show, id)

      conn = get(conn, Routes.vehicle_definition_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Vehicle definition"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.vehicle_definition_path(conn, :create), vehicle_definition: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Vehicle definition"
    end
  end

  describe "edit vehicle_definition" do
    setup [:create_vehicle_definition]

    test "renders form for editing chosen vehicle_definition", %{conn: conn, vehicle_definition: vehicle_definition} do
      conn = get(conn, Routes.vehicle_definition_path(conn, :edit, vehicle_definition))
      assert html_response(conn, 200) =~ "Edit Vehicle definition"
    end
  end

  describe "update vehicle_definition" do
    setup [:create_vehicle_definition]

    test "redirects when data is valid", %{conn: conn, vehicle_definition: vehicle_definition} do
      conn = put(conn, Routes.vehicle_definition_path(conn, :update, vehicle_definition), vehicle_definition: @update_attrs)
      assert redirected_to(conn) == Routes.vehicle_definition_path(conn, :show, vehicle_definition)

      conn = get(conn, Routes.vehicle_definition_path(conn, :show, vehicle_definition))
      assert html_response(conn, 200) =~ "some updated make"
    end

    test "renders errors when data is invalid", %{conn: conn, vehicle_definition: vehicle_definition} do
      conn = put(conn, Routes.vehicle_definition_path(conn, :update, vehicle_definition), vehicle_definition: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Vehicle definition"
    end
  end

  describe "delete vehicle_definition" do
    setup [:create_vehicle_definition]

    test "deletes chosen vehicle_definition", %{conn: conn, vehicle_definition: vehicle_definition} do
      conn = delete(conn, Routes.vehicle_definition_path(conn, :delete, vehicle_definition))
      assert redirected_to(conn) == Routes.vehicle_definition_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.vehicle_definition_path(conn, :show, vehicle_definition))
      end
    end
  end

  defp create_vehicle_definition(_) do
    vehicle_definition = fixture(:vehicle_definition)
    {:ok, vehicle_definition: vehicle_definition}
  end
end
