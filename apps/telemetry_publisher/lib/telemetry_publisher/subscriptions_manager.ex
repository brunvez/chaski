defmodule TelemetryPublisher.SubscriptionsManager do
  use GenServer
  alias TelemetryPublisher.Services.EntityManager, as: EntityManagerService
  alias TelemetryPublisher.Subscription
  alias TelemetryPublisher.SubscriptionWorker

  @logs_table :logs

  # Client

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def add_reading(%{"request_id" => request_id, "client_id" => client_id} = reading) do
    Task.start(fn ->
      :ets.insert(
        @logs_table,
        {request_id, :received_at, DateTime.to_unix(DateTime.utc_now(), :millisecond)}
      )
    end)

    Registry.dispatch(ReadingsPubSub, "devices.#{client_id}", fn entries ->
      for {pid, _} <- entries, do: send(pid, {:new_reading, reading})
    end)

    :ok
  end

  # Server (callbacks)

  @impl true
  def init(_) do
    :ets.new(@logs_table, [:bag, :public, :named_table])
    {:ok, %{workers: %{}}, {:continue, :fetch_subscriptions}}
  end

  @impl true
  def handle_continue(
        :fetch_subscriptions,
        state
      ) do
    with {:ok, subscriptions} <- Task.await(EntityManagerService.get_subscriptions()),
         subscriptions <- Enum.map(subscriptions, &Subscription.from_map/1) do
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
  def terminate(_reason, %{workers: workers}) do
    Enum.each(workers, fn {_, worker} ->
      DynamicSupervisor.terminate_child(SubscriptionsSupervisor, worker)
    end)
  end

  def da_bomb do
    alias Chaski.Devices
    alias Chaski.ClientApplications

    devices = Enum.map(1..70, fn i ->
        {:ok, device} = Devices.create_device(%{name: "Device #{i}"})
        device
      end)

    client_applications = Enum.map(1..1_000, fn i ->
        {:ok, client_application} =
          ClientApplications.create_client_application(%{name: "App #{i}"})

        client_application
      end)

    Enum.map(client_applications, fn client_application ->
      ClientApplications.create_subscription(
        %{
          name: "Sub #{client_application.id}",
          endpoint: "localhost:3033",
          delay: Enum.random(1_000..15_000)
        },
        client_application,
        [Enum.random(devices), Enum.random(devices)]
      )
    end)
  end
end
