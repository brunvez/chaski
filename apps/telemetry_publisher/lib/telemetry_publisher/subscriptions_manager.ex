defmodule TelemetryPublisher.SubscriptionsManager do
  use GenServer
  alias TelemetryPublisher.Services.EntityManager, as: EntityManagerService
  alias TelemetryPublisher.Subscription
  alias TelemetryPublisher.Subscription.Device
  alias TelemetryPublisher.SubscriptionWorker

  @subscriptions_table :subscriptions
  @device_subscriptions_table :subscription_devices
  @logs_table :logs

  # Client

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def add_reading(%{"request_id" => request_id} = reading) do
    Task.start(fn ->
      :ets.insert(
        @logs_table,
        {request_id, :received_at, DateTime.to_unix(DateTime.utc_now(), :millisecond)}
      )
    end)

    GenServer.cast(__MODULE__, {:add_reading, reading})
  end

  # Server (callbacks)

  @impl true
  def init(_) do
    {:ok, %{workers: %{}}, {:continue, :create_tables}}
  end

  @impl true
  def handle_continue(:create_tables, state) do
    subscriptions = :ets.new(@subscriptions_table, [:set, :protected])
    device_subscriptions_table = :ets.new(@device_subscriptions_table, [:bag, :protected])
    :ets.new(@logs_table, [:bag, :public, :named_table])

    {:noreply,
     Map.merge(state, %{
       subscriptions_table: subscriptions,
       device_subscriptions_table: device_subscriptions_table
     }), {:continue, :fetch_subscriptions}}
  end

  @impl true
  def handle_continue(
        :fetch_subscriptions,
        %{
          subscriptions_table: subscriptions_table,
          device_subscriptions_table: device_subscriptions_table
        } = state
      ) do
    with {:ok, subscriptions} <- Task.await(EntityManagerService.get_subscriptions()),
         subscriptions <- Enum.map(subscriptions, &Subscription.from_map/1) do
      Enum.each(subscriptions, fn %Subscription{id: subscription_id, devices: devices} =
                                    subscription ->
        :ets.insert(subscriptions_table, {subscription_id, subscription})

        Enum.each(devices, fn %Device{id: device_id} ->
          :ets.insert(device_subscriptions_table, {device_id, subscription_id})
        end)
      end)

      {:noreply, state, {:continue, {:initialize_workers, subscriptions}}}
    end
  end

  @impl true
  def handle_continue({:initialize_workers, subscriptions}, state) do
    workers =
      Enum.reduce(subscriptions, %{}, fn %Subscription{id: subscription_id} = subscription,
                                         workers ->
        worker_spec = %{
          id: "Subscription-#{subscription_id}",
          start: {SubscriptionWorker, :start_link, [subscription]}
        }

        {:ok, worker} = DynamicSupervisor.start_child(SubscriptionsSupervisor, worker_spec)

        Map.put(workers, subscription_id, worker)
      end)

    {:noreply, %{state | workers: workers}}
  end

  @impl true
  def handle_cast(
        {:add_reading, %{"device_id" => device_id} = reading},
        %{device_subscriptions_table: device_subscriptions_table, workers: workers} = state
      ) do
    subscription_ids = subscriptions_for_device(device_subscriptions_table, device_id)

    workers
    |> Map.take(subscription_ids)
    |> Map.values()
    |> Enum.each(fn worker -> send(worker, {:new_reading, reading}) end)

    {:noreply, state}
  end

  @impl true
  def terminate(_reason, %{workers: workers}) do
    Enum.each(workers, fn {_, worker} ->
      DynamicSupervisor.terminate_child(SubscriptionsSupervisor, worker)
    end)
  end

  defp subscriptions_for_device(device_subscriptions_table, device_id) do
    :ets.select(
      device_subscriptions_table,
      [{{:"$1", :"$2"}, [{:==, :"$1", device_id}], [:"$2"]}]
    )
  end
end
