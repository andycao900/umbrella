defmodule Engine.Repo.Migrations.CreateVehicleDefinitions do
  use Ecto.Migration

  def change do
    create table(:vehicle_definitions) do
      add :make, :string
      add :model, :string
      add :year, :integer

      timestamps()
    end

  end
end
