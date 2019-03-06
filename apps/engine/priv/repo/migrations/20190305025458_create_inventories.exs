defmodule Engine.Repo.Migrations.CreateInventories do
  use Ecto.Migration

  def change do
    create table(:inventories) do
      add :dealer_id, :string
      add :vehicle_id, references(:vehicles, on_delete: :nothing)

      timestamps()
    end

    create index(:inventories, [:vehicle_id])
  end
end
