defmodule AdminWeb.VehicleDefinitionController do
  use AdminWeb, :controller

  alias Engine.VMD
  alias Engine.VMD.VehicleDefinition

  def index(conn, _params) do
    vehicle_definitions = VMD.list_vehicle_definitions()
    render(conn, "index.html", vehicle_definitions: vehicle_definitions)
  end

  def new(conn, _params) do
    changeset = VMD.change_vehicle_definition(%VehicleDefinition{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"vehicle_definition" => vehicle_definition_params}) do
    case VMD.create_vehicle_definition(vehicle_definition_params) do
      {:ok, vehicle_definition} ->
        conn
        |> put_flash(:info, "Vehicle definition created successfully.")
        |> redirect(to: Routes.vehicle_definition_path(conn, :show, vehicle_definition))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    vehicle_definition = VMD.get_vehicle_definition!(id)
    render(conn, "show.html", vehicle_definition: vehicle_definition)
  end

  def edit(conn, %{"id" => id}) do
    vehicle_definition = VMD.get_vehicle_definition!(id)
    changeset = VMD.change_vehicle_definition(vehicle_definition)
    render(conn, "edit.html", vehicle_definition: vehicle_definition, changeset: changeset)
  end

  def update(conn, %{"id" => id, "vehicle_definition" => vehicle_definition_params}) do
    vehicle_definition = VMD.get_vehicle_definition!(id)

    case VMD.update_vehicle_definition(vehicle_definition, vehicle_definition_params) do
      {:ok, vehicle_definition} ->
        conn
        |> put_flash(:info, "Vehicle definition updated successfully.")
        |> redirect(to: Routes.vehicle_definition_path(conn, :show, vehicle_definition))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", vehicle_definition: vehicle_definition, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    vehicle_definition = VMD.get_vehicle_definition!(id)
    {:ok, _vehicle_definition} = VMD.delete_vehicle_definition(vehicle_definition)

    conn
    |> put_flash(:info, "Vehicle definition deleted successfully.")
    |> redirect(to: Routes.vehicle_definition_path(conn, :index))
  end
end
