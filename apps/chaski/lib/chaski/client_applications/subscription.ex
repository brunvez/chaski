defmodule Chaski.ClientApplications.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  alias Chaski.ClientApplications.ClientApplication
  alias Chaski.Devices.Device

  schema "subscriptions" do
    field :name, :string
    field :endpoint, :string
    field :delay, :integer
    belongs_to :client_application, ClientApplication
    many_to_many :devices, Device, join_through: "subscriptions_devices", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:name, :endpoint, :delay])
    |> validate_required([:name, :endpoint, :delay])
    |> assoc_constraint(:client_application)
  end
end
