defmodule Communication.Server do
  use GenServer
  alias Communication.Serializer
  alias Chaski.ClientApplications

  @queue_name "chaski.entity_manager"

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  @impl true
  def init(_) do
    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)

    {:ok, %{connection: connection, channel: channel}, {:continue, :declare_queue}}
  end

  @impl true
  def handle_continue(:declare_queue, %{channel: channel} = state) do
    AMQP.Queue.declare(channel, @queue_name)
    AMQP.Basic.qos(channel, prefetch_count: 1)
    AMQP.Basic.consume(channel, @queue_name)

    {:noreply, state}
  end

  @impl true
  def handle_info({:basic_deliver, payload, meta}, %{channel: channel} = state) do
    command = Jason.decode!(payload)

    Task.start(fn -> execute_command(command, channel, meta) end)

    {:noreply, state}
  end

  @impl true
  def handle_info(_, state) do
    {:noreply, state}
  end

  defp execute_command(%{"cmd" => "get_subscriptions"}, channel, meta) do
    subscriptions = ClientApplications.list_subscriptions()
    send_response({:ok, subscriptions}, channel, meta)
  end

  defp execute_command(command, _, _) do
    IO.inspect(command, label: "Command not registered")
  end

  defp send_response(response, channel, meta) do
    AMQP.Basic.publish(
      channel,
      "",
      meta.reply_to,
      build_response(response),
      correlation_id: meta.correlation_id
    )

    AMQP.Basic.ack(channel, meta.delivery_tag)
  end

  defp build_response({:ok, data}) do
    Jason.encode!(%{data: Serializer.serialize(data)})
  end

  defp build_response({:error, error}) do
    Jason.encode!(%{error: error})
  end
end
