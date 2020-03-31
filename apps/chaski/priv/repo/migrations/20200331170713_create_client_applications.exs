defmodule Chaski.Repo.Migrations.CreateClientApplications do
  use Ecto.Migration

  def change do
    create table(:client_applications) do
      add :name, :string

      timestamps()
    end

  end
end
