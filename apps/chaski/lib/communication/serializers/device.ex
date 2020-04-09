defimpl Communication.Serializer, for: Chaski.Devices.Device do
  def serialize(device),
    do: %{id: device.id, name: device.name, client_id: device.client_id}
end
