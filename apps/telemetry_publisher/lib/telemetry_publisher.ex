defmodule TelemetryPublisher do
  @moduledoc """
  Documentation for `TelemetryPublisher`.
  """

  def hello do
    :world
  end

  # 20_000 => 269 [consumers: 4, processors: 11, batchers: 5, batch_size: 100]
  # 20_000 => 197.8 [consumers: 4, processors: 11, batchers: 5, batch_size: 100]
  # 20_000 => 249.4 [consumers: 4, processors: 11, batchers: 5, batch_size: 100]
  # 20_000 => 287.4 [consumers: 4, processors: 11, batchers: 5, batch_size: 200]
  # 20_000 => 704.4 [consumers: 4, processors: 11, batchers: 5, batch_size: 500]
  # 20_000 => 704.4 [consumers: 4, processors: 50]
  def avg do
    times =
      :ets.tab2list(:logs)
      |> Enum.group_by(fn {id, _, _} -> id end)
      |> Enum.map(fn {_, times} ->
        {_, :sent_at, sent_at} = Enum.find(times, fn {_, event, _} -> event == :sent_at end)

        {_, :received_at, received_at} =
          Enum.find(times, fn {_, event, _} -> event == :received_at end)

        received_at - sent_at
      end)

    Enum.sum(times) / Enum.count(times)
  end

  def count do
    times =
      :ets.tab2list(:logs)
      |> Enum.group_by(fn {id, _, _} -> id end)
      |> Enum.map(fn {_, times} ->
        {_, :sent_at, sent_at} = Enum.find(times, fn {_, event, _} -> event == :sent_at end)

        {_, :received_at, received_at} =
          Enum.find(times, fn {_, event, _} -> event == :received_at end)

        received_at - sent_at
      end)

    Enum.count(times)
  end
end
