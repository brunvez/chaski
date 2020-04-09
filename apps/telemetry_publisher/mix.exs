defmodule TelemetryPublisher.MixProject do
  use Mix.Project

  def project do
    [
      app: :telemetry_publisher,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:lager, :logger, :amqp],
      mod: {TelemetryPublisher.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.1"},
      {:broadway_rabbitmq, "~> 0.6.0"},
      {:recase, "~> 0.5"},
      {:chaski, in_umbrella: true}
    ]
  end
end
