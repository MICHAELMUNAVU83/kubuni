defmodule Kubuni.Payments.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "payments" do
    field :status, Ecto.Enum, values: [:pending, :successful, :failed]
    field :currency, :string
    field :provider, Ecto.Enum, values: [:mpesa, :paystack]
    field :provider_reference, :string
    field :amount_minor, :integer
    field :raw_payload, :map
    field :paid_at, :utc_datetime
    belongs_to :user, Kubuni.Accounts.User
    belongs_to :course, Kubuni.Catalog.Course
    belongs_to :enrollment, Kubuni.Enrollments.Enrollment

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [
      :provider,
      :provider_reference,
      :amount_minor,
      :currency,
      :status,
      :raw_payload,
      :paid_at
    ])
    |> validate_required([
      :provider,
      :provider_reference,
      :amount_minor,
      :currency,
      :status,
      :paid_at
    ])
    |> unique_constraint(:provider_reference)
  end
end
