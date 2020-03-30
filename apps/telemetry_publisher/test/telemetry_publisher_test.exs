defmodule TelemetryPublisherTest do
  use ExUnit.Case
  doctest TelemetryPublisher

  test "greets the world" do
    assert TelemetryPublisher.hello() == :world
  end
end
