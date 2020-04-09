defmodule Chaski.Repo.Migrations.CreateSubscriptionsDevices do
  use Ecto.Migration

  def change do
    create table(:subscriptions_devices) do
      add :subscription_id, references(:subscriptions, on_delete: :delete_all), null: false
      add :device_id, references(:devices, on_delete: :delete_all), null: false
    end

    create index(:subscriptions_devices, [:subscription_id, :device_id])
  end
end
