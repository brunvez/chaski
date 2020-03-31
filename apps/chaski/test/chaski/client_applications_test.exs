defmodule Chaski.ClientApplicationsTest do
  use Chaski.DataCase

  alias Chaski.ClientApplications

  describe "client_applications" do
    alias Chaski.ClientApplications.ClientApplication

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def client_application_fixture(attrs \\ %{}) do
      {:ok, client_application} =
        attrs
        |> Enum.into(@valid_attrs)
        |> ClientApplications.create_client_application()

      client_application
    end

    test "list_client_applications/0 returns all client_applications" do
      client_application = client_application_fixture()
      assert ClientApplications.list_client_applications() == [client_application]
    end

    test "get_client_application!/1 returns the client_application with given id" do
      client_application = client_application_fixture()
      assert ClientApplications.get_client_application!(client_application.id) == client_application
    end

    test "create_client_application/1 with valid data creates a client_application" do
      assert {:ok, %ClientApplication{} = client_application} = ClientApplications.create_client_application(@valid_attrs)
      assert client_application.name == "some name"
    end

    test "create_client_application/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ClientApplications.create_client_application(@invalid_attrs)
    end

    test "update_client_application/2 with valid data updates the client_application" do
      client_application = client_application_fixture()
      assert {:ok, %ClientApplication{} = client_application} = ClientApplications.update_client_application(client_application, @update_attrs)
      assert client_application.name == "some updated name"
    end

    test "update_client_application/2 with invalid data returns error changeset" do
      client_application = client_application_fixture()
      assert {:error, %Ecto.Changeset{}} = ClientApplications.update_client_application(client_application, @invalid_attrs)
      assert client_application == ClientApplications.get_client_application!(client_application.id)
    end

    test "delete_client_application/1 deletes the client_application" do
      client_application = client_application_fixture()
      assert {:ok, %ClientApplication{}} = ClientApplications.delete_client_application(client_application)
      assert_raise Ecto.NoResultsError, fn -> ClientApplications.get_client_application!(client_application.id) end
    end

    test "change_client_application/1 returns a client_application changeset" do
      client_application = client_application_fixture()
      assert %Ecto.Changeset{} = ClientApplications.change_client_application(client_application)
    end
  end
end
