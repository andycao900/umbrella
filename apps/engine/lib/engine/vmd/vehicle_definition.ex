defmodule Engine.VMD.VehicleDefinition do
  use Ecto.Schema
  import Ecto.Changeset


  schema "vehicle_definitions" do
    field :make, :string
    field :model, :string
    field :year, :integer

    timestamps()
  end

  @doc false
  def changeset(vehicle_definition, attrs) do
    vehicle_definition
    |> cast(attrs, [:make, :model, :year])
    |> validate_required([:make, :model, :year])
  end
end
