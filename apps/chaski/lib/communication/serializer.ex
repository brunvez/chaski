defprotocol Communication.Serializer do
  @spec serialize(t) :: Map.t()
  def serialize(value)
end

defimpl Communication.Serializer, for: List do
  def serialize(list), do: Enum.map(list, &Communication.Serializer.serialize/1)
end

defimpl Communication.Serializer, for: Map do
  def serialize(map), do: map
end
