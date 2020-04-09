defmodule ChaskiWeb.Api.V1.SubscriptionController do
  use ChaskiWeb, :controller

  alias Chaski.ClientApplications
  alias Chaski.ClientApplications.Subscription
  alias Chaski.Devices

  action_fallback ChaskiWeb.FallbackController

  def index(conn, _params) do
    subscriptions = ClientApplications.list_subscriptions()
    render(conn, "index.json", subscriptions: subscriptions)
  end

  def create(conn, %{
        "subscription" => subscription_params,
        "devices" => device_ids,
        "client_application_id" => client_application_id
      }) do
    with client_application <- ClientApplications.get_client_application!(client_application_id),
         devices <- Devices.get_devices(device_ids),
         {:ok, %Subscription{} = subscription} <-
           ClientApplications.create_subscription(
             subscription_params,
             client_application,
             devices
           ) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        Routes.api_v1_client_application_subscription_path(
          conn,
          :show,
          client_application_id,
          subscription
        )
      )
      |> render("show.json", subscription: subscription)
    end
  end

  def show(conn, %{"id" => id}) do
    subscription = ClientApplications.get_subscription!(id)
    render(conn, "show.json", subscription: subscription)
  end

  def update(conn, %{"id" => id, "subscription" => subscription_params}) do
    subscription = ClientApplications.get_subscription!(id)

    with {:ok, %Subscription{} = subscription} <-
           ClientApplications.update_subscription(subscription, subscription_params) do
      render(conn, "show.json", subscription: subscription)
    end
  end

  def delete(conn, %{"id" => id}) do
    subscription = ClientApplications.get_subscription!(id)

    with {:ok, %Subscription{}} <- ClientApplications.delete_subscription(subscription) do
      send_resp(conn, :no_content, "")
    end
  end
end
