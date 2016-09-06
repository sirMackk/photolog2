defmodule Photolog2.Repo.Migrations.CreateAlbumsAndPhotos do
  use Ecto.Migration

  def change do
    create table(:albums) do
      add :name, :string
      add :description, :text
      add :status, :integer, default: 0
      add :user_id, references(:users, on_delete: :nothing)

      timestamps
    end

    create index(:albums, [:name])
    create index(:albums, [:user_id])
    create index(:albums, [:status])

    create table(:photos) do
      add :name, :string
      add :file_name, :string
      add :description, :text
      add :album_id, references(:albums, on_delete: :nothing)

      timestamps
    end

    create index(:photos, [:album_id])
  end
end
