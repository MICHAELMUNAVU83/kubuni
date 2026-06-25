defmodule Kubuni.Payments.Workers.ReconcilePendingPayments do
  use Oban.Worker,
    queue: :payments,
    max_attempts: 5,
    unique: [period: 55, fields: [:worker]]

  alias Kubuni.Payments

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    Payments.list_stale_pending_payments()
    |> Enum.each(fn payment ->
      %{"reference" => payment.provider_reference, "event" => %{"event" => "reconciliation"}}
      |> Kubuni.Payments.Workers.ProcessPaystackWebhook.new()
      |> Oban.insert()
    end)

    :ok
  end
end
