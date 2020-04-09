defmodule TelemetryPublisher.Services.EntityManager do
  use GenServer
  alias TelemetryPublisher.RPCClient

  @queue_name "chaski.entity_manager"

  # Client

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def get_subscriptions do
    Task.async(fn ->
      GenServer.call(__MODULE__, {:get_subscriptions})
    end)
  end

  # Server (callbacks)

  @impl true
  def init(_opts) do
    with {:ok, connection} <- AMQP.Connection.open(),
         {:ok, channel} <- AMQP.Channel.open(connection),
         service <- RPCClient.create_service(EntityManager, queue_name: @queue_name) do
      state = %{connection: connection, channel: channel, service: service}
      {:ok, state}
    else
      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_call({:get_subscriptions}, _from, %{channel: channel, service: service} = state) do
    result =
      RPCClient.call(channel, service, %{
        "cmd" => "get_subscriptions"
      })

    {:reply, result, state}
  end

  @impl true
  def terminate(_reason, %{connection: connection}) do
    AMQP.Connection.close(connection)
  end
end
