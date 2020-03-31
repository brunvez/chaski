defmodule Chaski.Repo do
  use Ecto.Repo,
    otp_app: :chaski,
    adapter: Ecto.Adapters.Postgres
end
