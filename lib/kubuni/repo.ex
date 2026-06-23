defmodule Kubuni.Repo do
  use Ecto.Repo,
    otp_app: :kubuni,
    adapter: Ecto.Adapters.Postgres
end
