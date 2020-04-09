defimpl Communication.Serializer, for: Chaski.ClientApplications.Subscription do
  def serialize(subscription),
    do: %{
      id: subscription.id,
      name: subscription.name,
      endpoint: subscription.endpoint,
      delay: subscription.delay,
      devices: Enum.map(subscription.devices, &Communication.Serializer.serialize/1)
    }
end
