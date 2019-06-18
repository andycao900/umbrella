defmodule Engine.Repo.Migrations.CreatePermissions do
  use Ecto.Migration

  def change do
    create table(:permissions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :text, null: false

      timestamps()
    end

    create unique_index(:permissions, :name)
  end
end
