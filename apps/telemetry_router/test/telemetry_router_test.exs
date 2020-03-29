defmodule TelemetryRouterTest do
  use ExUnit.Case
  doctest TelemetryRouter

  test "greets the world" do
    assert TelemetryRouter.hello() == :world
  end
end
