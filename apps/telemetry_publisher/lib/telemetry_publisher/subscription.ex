defmodule TelemetryPublisher.Subscription do
  alias TelemetryPublisher.Subscription

  @derive Jason.Encoder
  defstruct([:id, :delay, :endpoint, :devices])

  defmodule Device do
    @derive Jason.Encoder
    defstruct([:id, :client_id])
  end

  def from_map(map) do
    create_subscription(map)
  end

  defp create_subscription(%{
         "id" => id,
         "delay" => delay,
         "endpoint" => endpoint,
         "devices" => devices
       }),
       do: %Subscription{
         id: id,
         delay: delay,
         endpoint: endpoint,
         devices: Enum.map(devices, &create_device/1)
       }

  defp create_device(%{"id" => id, "client_id" => client_id}),
    do: %Device{id: id, client_id: client_id}
end
