defmodule Engine.VMD.Vehicle do
  @moduledoc """
  Schema for Vehicle
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "vehicles" do
    field :vin, :string
    field :vehicle_definition_id, :id

    timestamps()
  end

  @doc false
  def changeset(vehicle, attrs) do
    vehicle
    |> cast(attrs, [:vin])
    |> validate_required([:vin])
  end
end
