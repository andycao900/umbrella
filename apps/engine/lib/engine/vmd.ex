defmodule Engine.VMD do
  @moduledoc """
  The VMD context.
  """

  import Ecto.Query, warn: false
  alias Engine.Repo

  alias Engine.VMD.VehicleDefinition

  @doc """
  Returns the list of vehicle_definitions.

  ## Examples

      iex> list_vehicle_definitions()
      [%VehicleDefinition{}, ...]

  """
  def list_vehicle_definitions do
    Repo.all(VehicleDefinition)
  end

  @doc """
  Gets a single vehicle_definition.

  Raises `Ecto.NoResultsError` if the Vehicle definition does not exist.

  ## Examples

      iex> get_vehicle_definition!(123)
      %VehicleDefinition{}

      iex> get_vehicle_definition!(456)
      ** (Ecto.NoResultsError)

  """
  def get_vehicle_definition!(id), do: Repo.get!(VehicleDefinition, id)

  @doc """
  Creates a vehicle_definition.

  ## Examples

      iex> create_vehicle_definition(%{field: value})
      {:ok, %VehicleDefinition{}}

      iex> create_vehicle_definition(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_vehicle_definition(attrs \\ %{}) do
    %VehicleDefinition{}
    |> VehicleDefinition.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a vehicle_definition.

  ## Examples

      iex> update_vehicle_definition(vehicle_definition, %{field: new_value})
      {:ok, %VehicleDefinition{}}

      iex> update_vehicle_definition(vehicle_definition, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_vehicle_definition(%VehicleDefinition{} = vehicle_definition, attrs) do
    vehicle_definition
    |> VehicleDefinition.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a VehicleDefinition.

  ## Examples

      iex> delete_vehicle_definition(vehicle_definition)
      {:ok, %VehicleDefinition{}}

      iex> delete_vehicle_definition(vehicle_definition)
      {:error, %Ecto.Changeset{}}

  """
  def delete_vehicle_definition(%VehicleDefinition{} = vehicle_definition) do
    Repo.delete(vehicle_definition)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vehicle_definition changes.

  ## Examples

      iex> change_vehicle_definition(vehicle_definition)
      %Ecto.Changeset{source: %VehicleDefinition{}}

  """
  def change_vehicle_definition(%VehicleDefinition{} = vehicle_definition) do
    VehicleDefinition.changeset(vehicle_definition, %{})
  end

  alias Engine.VMD.Vehicle

  @doc """
  Returns the list of vehicles.

  ## Examples

      iex> list_vehicles()
      [%Vehicle{}, ...]

  """
  def list_vehicles do
    Repo.all(Vehicle)
  end

  @doc """
  Gets a single vehicle.

  Raises `Ecto.NoResultsError` if the Vehicle does not exist.

  ## Examples

      iex> get_vehicle!(123)
      %Vehicle{}

      iex> get_vehicle!(456)
      ** (Ecto.NoResultsError)

  """
  def get_vehicle!(id), do: Repo.get!(Vehicle, id)

  @doc """
  Creates a vehicle.

  ## Examples

      iex> create_vehicle(%{field: value})
      {:ok, %Vehicle{}}

      iex> create_vehicle(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_vehicle(attrs \\ %{}) do
    %Vehicle{}
    |> Vehicle.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a vehicle.

  ## Examples

      iex> update_vehicle(vehicle, %{field: new_value})
      {:ok, %Vehicle{}}

      iex> update_vehicle(vehicle, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_vehicle(%Vehicle{} = vehicle, attrs) do
    vehicle
    |> Vehicle.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Vehicle.

  ## Examples

      iex> delete_vehicle(vehicle)
      {:ok, %Vehicle{}}

      iex> delete_vehicle(vehicle)
      {:error, %Ecto.Changeset{}}

  """
  def delete_vehicle(%Vehicle{} = vehicle) do
    Repo.delete(vehicle)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vehicle changes.

  ## Examples

      iex> change_vehicle(vehicle)
      %Ecto.Changeset{source: %Vehicle{}}

  """
  def change_vehicle(%Vehicle{} = vehicle) do
    Vehicle.changeset(vehicle, %{})
  end
end
