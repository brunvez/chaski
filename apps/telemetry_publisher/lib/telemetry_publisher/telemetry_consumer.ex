defmodule TelemetryPublisher.TelemetryConsumer do
  use Broadway
  alias Broadway.Message
  alias TelemetryPublisher.SubscriptionsManager

  @telemetry_queue "chaski.telemetry"

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: TelemetryConsumer,
      producer: [
        module:
          {BroadwayRabbitMQ.Producer,
           queue: @telemetry_queue,
           qos: [
             prefetch_count: 150
           ]},
        concurrency: 4
      ],
      processors: [
        default: [
          concurrency: 50
        ]
      ]
    )
  end

  def handle_message(_, %Message{data: reading} = message, _) do
    SubscriptionsManager.add_reading(Jason.decode!(reading))

    message
  end
end
