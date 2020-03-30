defmodule TelemetryPublisher.RPCClient do
  defmodule Service, do: defstruct([:name, :queue_name])

  def create_service(name, queue_name: queue_name) do
    %Service{name: name, queue_name: queue_name}
  end

  def call(channel, %Service{queue_name: service_queue}, command) do
    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)

    {:ok, %{queue: reply_queue}} =
      AMQP.Queue.declare(
        channel,
        "",
        exclusive: true
      )

    AMQP.Basic.consume(channel, reply_queue, nil, no_ack: true)

    correlation_id =
      :erlang.unique_integer()
      |> :erlang.integer_to_binary()
      |> Base.encode64()

    request = Jason.encode!(command)

    AMQP.Basic.publish(
      channel,
      "",
      service_queue,
      request,
      reply_to: reply_queue,
      correlation_id: correlation_id
    )

    wait_for_messages(channel, correlation_id)
  end

  defp wait_for_messages(_channel, correlation_id) do
    receive do
      {:basic_deliver, payload, %{correlation_id: ^correlation_id}} ->
        convert_response(Jason.decode!(payload))
    end
  end

  defp convert_response(%{"err" => err}) when not is_nil(err) do
    {:error, err}
  end

  defp convert_response(%{"response" => response}) when is_list(response) do
    {:ok, Enum.map(response, &keys_to_snake_case/1)}
  end

  defp convert_response(%{"response" => response}) when is_map(response) do
    {:ok, keys_to_snake_case(response)}
  end

  defp convert_response(%{"response" => response}) do
    {:ok, response}
  end

  defp keys_to_snake_case(map) do
    Enum.reduce(map, %{}, fn
      {key, value}, acc when is_list(value) ->
        Map.put(acc, Recase.to_snake(key), Enum.map(value, &keys_to_snake_case/1))

      {key, value}, acc when is_map(value) ->
        Map.put(acc, Recase.to_snake(key), keys_to_snake_case(value))

      {key, value}, acc ->
        Map.put(acc, Recase.to_snake(key), value)
    end)
  end
end
