defmodule Engine.Repo.Migrations.CreateVehicles do
  use Ecto.Migration

  def change do
    create table(:vehicles) do
      add :vin, :string
      add :vehicle_definition_id, references(:vehicle_definitions, on_delete: :nothing)

      timestamps()
    end

    create index(:vehicles, [:vehicle_definition_id])
  end
end
