defmodule ChaskiWeb.Api.V1.ClientApplicationView do
  use ChaskiWeb, :view
  alias ChaskiWeb.Api.V1.ClientApplicationView

  def render("index.json", %{client_applications: client_applications}) do
    %{data: render_many(client_applications, ClientApplicationView, "client_application.json")}
  end

  def render("show.json", %{client_application: client_application}) do
    %{data: render_one(client_application, ClientApplicationView, "client_application.json")}
  end

  def render("client_application.json", %{client_application: client_application}) do
    %{id: client_application.id,
      name: client_application.name}
  end
end
