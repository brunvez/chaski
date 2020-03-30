defmodule TelemetryRouter.TelemetrySender do
  use GenServer

  @telemetry_queue "chaski.telemetry"
  @logs_table :logs

  defmodule Message do
    @derive Jason.Encoder
    defstruct [:device_id, :payload, :request_id]
  end

  # Client

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def send(device_id, payload) do
    GenServer.cast(__MODULE__, {:queue_telemetry, device_id, payload})
  end

  # Server (callbacks)

  @impl true
  def init(_opts) do
    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)
    unless :ets.whereis(@logs_table), do: :ets.new(@logs_table, [:bag, :public, :named_table])

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
      queue_message(channel, device_id, payload)
    end)

    {:noreply, state}
  end

  @impl true
  def terminate(_reason, %{connection: connection}) do
    AMQP.Connection.close(connection)
  end

  defp queue_message(channel, device_id, payload) do
    request_id =
      :erlang.unique_integer()
      |> :erlang.integer_to_binary()
      |> Base.encode64()

    message = %Message{
      device_id: device_id,
      payload: Jason.decode!(payload),
      request_id: request_id
    }

    Task.start(fn ->
      :ets.insert(
        @logs_table,
        {request_id, :sent_at, DateTime.to_unix(DateTime.utc_now(), :millisecond)}
      )
    end)

    :ok = AMQP.Basic.publish(channel, @telemetry_queue, "", Jason.encode!(message))
  end
end
