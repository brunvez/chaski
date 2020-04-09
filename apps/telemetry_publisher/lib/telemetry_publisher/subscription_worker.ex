defmodule TelemetryPublisher.SubscriptionWorker do
  use GenServer
  alias TelemetryPublisher.Subscription
  alias TelemetryPublisher.Subscription.Device

  # Client

  def start_link(subscription) do
    GenServer.start_link(__MODULE__, subscription, name: :"SubscriptionWorker-#{subscription.id}")
  end

  # Server (callbacks)

  @impl true
  def init(subscription) do
    schedule_next_message(subscription)

    Enum.each(subscription.devices, fn device ->
      {:ok, _} = Registry.register(ReadingsPubSub, "devices.#{device.client_id}", [])
    end)

    {:ok, %{subscription: subscription, readings: []}}
  end

  @impl true
  def handle_info(:send_telemetry, %{subscription: subscription, readings: readings} = state) do
    schedule_next_message(subscription)
    Task.start(fn -> send_telemetry(subscription, readings) end)

    {:noreply, %{state | readings: []}}
  end

  @impl true
  def handle_info({:new_reading, reading}, %{readings: readings} = state) do
    readings = [reading | readings]

    {:noreply, %{state | readings: readings}}
  end

  defp schedule_next_message(%Subscription{delay: delay}) do
    Process.send_after(self(), :send_telemetry, delay)
  end

  defp send_telemetry(_, []), do: :ok

  defp send_telemetry(%Subscription{endpoint: endpoint} = subscription, readings) do
    readings = readings |> group_readings() |> translate_ids(subscription)

    resp =
      HTTPoison.post(endpoint, Jason.encode!(%{readings: readings}), [
        {"Content-Type", "application/json"}
      ])

    case resp do
      {:error, reason} ->
        IO.inspect({:error, reason, subscription})
        :error

      _ ->
        :ok
    end
  end

  defp group_readings(readings) do
    Enum.reduce(readings, %{}, fn %{"client_id" => client_id, "payload" => payload}, acc ->
      Map.update(acc, client_id, [payload], &[payload | &1])
    end)
  end

  defp translate_ids(readings, %Subscription{devices: devices}) do
    Enum.reduce(readings, %{}, fn {client_id, value}, acc ->
      %Device{id: device_id} = Enum.find(devices, &(&1.client_id == client_id))

      Map.put(acc, device_id, value)
    end)
  end
end
