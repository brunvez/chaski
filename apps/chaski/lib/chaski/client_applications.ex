defmodule Chaski.ClientApplications do
  @moduledoc """
  The ClientApplications context.
  """

  import Ecto.Query, warn: false
  alias Chaski.Repo

  alias Chaski.ClientApplications.ClientApplication

  @doc """
  Returns the list of client_applications.

  ## Examples

      iex> list_client_applications()
      [%ClientApplication{}, ...]

  """
  def list_client_applications do
    Repo.all(ClientApplication)
  end

  @doc """
  Gets a single client_application.

  Raises `Ecto.NoResultsError` if the Client application does not exist.

  ## Examples

      iex> get_client_application!(123)
      %ClientApplication{}

      iex> get_client_application!(456)
      ** (Ecto.NoResultsError)

  """
  def get_client_application!(id), do: Repo.get!(ClientApplication, id)

  @doc """
  Creates a client_application.

  ## Examples

      iex> create_client_application(%{field: value})
      {:ok, %ClientApplication{}}

      iex> create_client_application(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_client_application(attrs \\ %{}) do
    %ClientApplication{}
    |> ClientApplication.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a client_application.

  ## Examples

      iex> update_client_application(client_application, %{field: new_value})
      {:ok, %ClientApplication{}}

      iex> update_client_application(client_application, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_client_application(%ClientApplication{} = client_application, attrs) do
    client_application
    |> ClientApplication.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a client_application.

  ## Examples

      iex> delete_client_application(client_application)
      {:ok, %ClientApplication{}}

      iex> delete_client_application(client_application)
      {:error, %Ecto.Changeset{}}

  """
  def delete_client_application(%ClientApplication{} = client_application) do
    Repo.delete(client_application)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking client_application changes.

  ## Examples

      iex> change_client_application(client_application)
      %Ecto.Changeset{source: %ClientApplication{}}

  """
  def change_client_application(%ClientApplication{} = client_application) do
    ClientApplication.changeset(client_application, %{})
  end
end
