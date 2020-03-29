defmodule TelemetryRouter.TelemetrySender do
  use GenServer

  @telemetry_queue "chaski.telemetry"

  # Client

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def send(device_id, payload) do
    GenServer.cast(__MODULE__, {:queue_telemetry, device_id, payload})
  end

  # Server (callbacks)

  @impl true
  def init(stack) do
    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)

    state = %{connection: connection, channel: channel}
    {:ok, state, {:continue, :create_queue}}
  end

  @impl true
  def handle_continue(:create_queue, %{channel: channel} = state) do
    {:ok, _} =
      AMQP.Queue.declare(channel, @telemetry_queue,
        durable: true,
        arguments: [{"x-queue-type", :longstr, "classic"}]
      )

    {:noreply, state}
  end

  @impl true
  def handle_cast({:queue_telemetry, device_id, payload}, %{channel: channel} = state) do
    Task.start(fn ->
      :ok =
        AMQP.Basic.publish(channel, @telemetry_queue, "", payload,
          headers: [{"device-id", :longstr, device_id}]
        )
    end)

    {:noreply, state}
  end

  @impl true
  def terminate(_reason, %{connection: connection}) do
    AMQP.Connection.close(connection)
  end
end
