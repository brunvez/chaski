defmodule Chaski.Repo.Migrations.CreateDevices do
  use Ecto.Migration

  def change do
    create table(:devices) do
      add :name, :string
      add :client_id, :binary_id

      timestamps()
    end

    create index(:devices, [:client_id])
  end
end
