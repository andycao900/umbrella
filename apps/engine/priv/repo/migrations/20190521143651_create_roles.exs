defmodule Engine.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :text, null: false

      timestamps()
    end

    create unique_index(:roles, :name)
  end
end
