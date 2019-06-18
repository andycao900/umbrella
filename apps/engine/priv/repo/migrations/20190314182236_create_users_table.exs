defmodule Engine.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :auth0_id, :string, null: false
      add :avatar_url, :string
      add :email, :string
      add :email_verified, :boolean, default: false
      add :last_signed_in_at, :utc_datetime
      add :name, :string
      add :type, :string

      timestamps()
    end

    create unique_index(:users, :auth0_id)
  end
end
