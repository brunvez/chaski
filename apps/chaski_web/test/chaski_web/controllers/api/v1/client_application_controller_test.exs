defmodule ChaskiWeb.API.V1.ClientApplicationControllerTest do
  use ChaskiWeb.ConnCase

  alias Chaski.ClientApplications
  alias Chaski.ClientApplications.ClientApplication

  @create_attrs %{
    name: "some name"
  }
  @update_attrs %{
    name: "some updated name"
  }
  @invalid_attrs %{name: nil}

  def fixture(:client_application) do
    {:ok, client_application} = ClientApplications.create_client_application(@create_attrs)
    client_application
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all client_applications", %{conn: conn} do
      conn = get(conn, Routes.api_v1_client_application_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create client_application" do
    test "renders client_application when data is valid", %{conn: conn} do
      conn = post(conn, Routes.api_v1_client_application_path(conn, :create), client_application: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.api_v1_client_application_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.api_v1_client_application_path(conn, :create), client_application: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update client_application" do
    setup [:create_client_application]

    test "renders client_application when data is valid", %{conn: conn, client_application: %ClientApplication{id: id} = client_application} do
      conn = put(conn, Routes.api_v1_client_application_path(conn, :update, client_application), client_application: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.api_v1_client_application_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, client_application: client_application} do
      conn = put(conn, Routes.api_v1_client_application_path(conn, :update, client_application), client_application: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete client_application" do
    setup [:create_client_application]

    test "deletes chosen client_application", %{conn: conn, client_application: client_application} do
      conn = delete(conn, Routes.api_v1_client_application_path(conn, :delete, client_application))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.api_v1_client_application_path(conn, :show, client_application))
      end
    end
  end

  defp create_client_application(_) do
    client_application = fixture(:client_application)
    {:ok, client_application: client_application}
  end
end
