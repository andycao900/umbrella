defmodule Engine.InventoryTracker.Inventory do
  use Ecto.Schema
  import Ecto.Changeset


  schema "inventories" do
    field :dealer_id, :string
    field :vehicle_id, :id
    field :make, :string, virtual: true
    field :model, :string, virtual: true
    field :year, :integer, virtual: true
    field :vin, :string, virtual: true
    field :external_dealer_id, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(inventory, attrs) do
    inventory
    |> cast(attrs, [:dealer_id])
    |> validate_required([:dealer_id])
  end

    @doc false
    def cpo_changeset(inventory, attrs) do
      inventory
      |> cast(attrs, [:dealer_id, :vehicle_id, :make, :model, :year, :vin, :external_dealer_id])
      |> validate_required([:make, :model, :year, :vin, :external_dealer_id])
    end
end
