defmodule Chaski.ClientApplications do
  @moduledoc """
  The ClientApplications context.
  """

  import Ecto.Query, warn: false
  alias Chaski.Repo

  alias Chaski.ClientApplications.ClientApplication
  alias Chaski.ClientApplications.Subscription
  alias Chaski.Devices

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

  @doc """
  Returns the list of subscriptions.

  ## Examples

      iex> list_subscriptions()
      [%Subscription{}, ...]

  """
  def list_subscriptions do
    Subscription
    |> Repo.all()
    |> Repo.preload(:devices)
  end

  @doc """
  Gets a single subscription.

  Raises `Ecto.NoResultsError` if the Subscription does not exist.

  ## Examples

      iex> get_subscription!(123)
      %Subscription{}

      iex> get_subscription!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscription!(id), do: Repo.get!(Subscription, id)

  @doc """
  Creates a subscription.

  ## Examples

      iex> create_subscription(%{field: value})
      {:ok, %Subscription{}}

      iex> create_subscription(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscription(attrs, client_application, devices) do
    with {:ok, subscription} <-
           %Subscription{}
           |> Subscription.changeset(attrs)
           |> Ecto.Changeset.put_assoc(:client_application, client_application)
           |> Ecto.Changeset.put_assoc(:devices, devices)
           |> Repo.insert() do
      {:ok, Repo.preload(subscription, :devices)}
    end
  end

  @doc """
  Updates a subscription.

  ## Examples

      iex> update_subscription(subscription, %{field: new_value})
      {:ok, %Subscription{}}

      iex> update_subscription(subscription, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subscription(%Subscription{} = subscription, attrs) do
    subscription
    |> Subscription.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a subscription.

  ## Examples

      iex> delete_subscription(subscription)
      {:ok, %Subscription{}}

      iex> delete_subscription(subscription)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subscription(%Subscription{} = subscription) do
    Repo.delete(subscription)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscription changes.

  ## Examples

      iex> change_subscription(subscription)
      %Ecto.Changeset{source: %Subscription{}}

  """
  def change_subscription(%Subscription{} = subscription) do
    Subscription.changeset(subscription, %{})
  end
end
