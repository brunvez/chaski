defmodule Chaski.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :name, :string, null: false
      add :endpoint, :string, null: false
      add :delay, :integer, null: false

      add :client_application_id, references(:client_applications, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create index(:subscriptions, [:client_application_id])
  end
end
