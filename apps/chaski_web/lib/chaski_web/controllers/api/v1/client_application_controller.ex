defmodule ChaskiWeb.Api.V1.ClientApplicationController do
  use ChaskiWeb, :controller

  alias Chaski.ClientApplications
  alias Chaski.ClientApplications.ClientApplication

  action_fallback ChaskiWeb.FallbackController

  def index(conn, _params) do
    client_applications = ClientApplications.list_client_applications()
    render(conn, "index.json", client_applications: client_applications)
  end

  def create(conn, %{"client_application" => client_application_params}) do
    with {:ok, %ClientApplication{} = client_application} <-
           ClientApplications.create_client_application(client_application_params) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        Routes.api_v1_client_application_path(conn, :show, client_application)
      )
      |> render("show.json", client_application: client_application)
    end
  end

  def show(conn, %{"id" => id}) do
    client_application = ClientApplications.get_client_application!(id)
    render(conn, "show.json", client_application: client_application)
  end

  def update(conn, %{"id" => id, "client_application" => client_application_params}) do
    client_application = ClientApplications.get_client_application!(id)

    with {:ok, %ClientApplication{} = client_application} <-
           ClientApplications.update_client_application(
             client_application,
             client_application_params
           ) do
      render(conn, "show.json", client_application: client_application)
    end
  end

  def delete(conn, %{"id" => id}) do
    client_application = ClientApplications.get_client_application!(id)

    with {:ok, %ClientApplication{}} <-
           ClientApplications.delete_client_application(client_application) do
      send_resp(conn, :no_content, "")
    end
  end
end
