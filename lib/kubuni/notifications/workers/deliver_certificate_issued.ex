defmodule Kubuni.Notifications.Workers.DeliverCertificateIssued do
  @moduledoc false

  use Oban.Worker,
    queue: :mailers,
    max_attempts: 10,
    unique: [period: :infinity, fields: [:worker, :args], keys: [:certificate_id]]

  alias Kubuni.Accounts.UserNotifier
  alias Kubuni.Certificates
  alias Kubuni.Repo

  def new(certificate_id), do: __MODULE__.new(%{certificate_id: certificate_id})

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"certificate_id" => certificate_id}}) do
    certificate =
      certificate_id
      |> Certificates.get_certificate!()
      |> Repo.preload([:user, :course, :module])

    UserNotifier.deliver_certificate_issued(certificate)
  end
end
