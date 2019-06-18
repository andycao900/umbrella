defmodule Engine.Repo.Migrations.CreateRolePermissions do
  use Ecto.Migration

  def change do
    create table(:role_permissions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :role_id, references(:roles, type: :uuid, on_delete: :delete_all), null: false

      add :permission_id, references(:permissions, type: :uuid, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create unique_index(:role_permissions, [:role_id, :permission_id])
  end
end
