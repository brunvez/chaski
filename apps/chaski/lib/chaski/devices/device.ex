defmodule Chaski.Devices.Device do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset
  alias Chaski.Devices.Device

  schema "devices" do
    field :name, :string
    field :client_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(device, attrs) do
    device
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> add_client_id()
  end

  defp add_client_id(%Changeset{data: %Device{client_id: nil}} = changeset) do
    put_change(changeset, :client_id, Ecto.UUID.generate())
  end

  defp add_client_id(changeset), do: changeset
end
