defmodule TelemetryRouter.Subscriber do
  use Supervisor

  @broker_host "localhost"
  @broker_port 1883

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children = [
      {Tortoise.Connection,
       [
         client_id: TelemetryRouter,
         server: {Tortoise.Transport.Tcp, host: @broker_host, port: @broker_port},
         handler: {TelemetryRouter.TelemetryHandler, []},
         subscriptions: ["chaski/+/telemetry"]
       ]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
