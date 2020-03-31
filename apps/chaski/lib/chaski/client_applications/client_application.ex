defmodule Chaski.ClientApplications.ClientApplication do
  use Ecto.Schema
  import Ecto.Changeset

  schema "client_applications" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(client_application, attrs) do
    client_application
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
