defmodule ChaskiWeb.Router do
  use ChaskiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ChaskiWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api/v1", ChaskiWeb.Api.V1, as: :api_v1 do
    pipe_through :api

    resources "/devices", DeviceController
    resources "/client_applications", ClientApplicationController
  end
end
