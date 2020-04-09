defmodule Chaski.ClientApplications.ClientApplication do
  use Ecto.Schema
  import Ecto.Changeset

  alias Chaski.ClientApplications.Subscription

  schema "client_applications" do
    field :name, :string
    has_many :subscriptions, Subscription

    timestamps()
  end

  @doc false
  def changeset(client_application, attrs) do
    client_application
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
