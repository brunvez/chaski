defmodule ChaskiWeb.Api.V1.DeviceView do
  use ChaskiWeb, :view
  alias ChaskiWeb.Api.V1.DeviceView

  def render("index.json", %{devices: devices}) do
    %{data: render_many(devices, DeviceView, "device.json")}
  end

  def render("show.json", %{device: device}) do
    %{data: render_one(device, DeviceView, "device.json")}
  end

  def render("device.json", %{device: device}) do
    %{id: device.id, name: device.name, client_id: device.client_id}
  end
end
