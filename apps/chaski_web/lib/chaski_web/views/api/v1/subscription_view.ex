defmodule ChaskiWeb.Api.V1.SubscriptionView do
  use ChaskiWeb, :view
  alias ChaskiWeb.Api.V1.SubscriptionView
  alias ChaskiWeb.Api.V1.DeviceView

  def render("index.json", %{subscriptions: subscriptions}) do
    %{data: render_many(subscriptions, SubscriptionView, "subscription.json")}
  end

  def render("show.json", %{subscription: subscription}) do
    %{data: render_one(subscription, SubscriptionView, "subscription.json")}
  end

  def render("subscription.json", %{subscription: subscription}) do
    %{
      id: subscription.id,
      name: subscription.name,
      endpoint: subscription.endpoint,
      delay: subscription.delay,
      devices: Enum.map(subscription.devices, &DeviceView.render("device.json", %{device: &1}))
    }
  end
end
