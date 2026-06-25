defmodule Kubuni.PaymentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Kubuni.Payments` context.
  """

  @doc """
  Generate a unique payment provider_reference.
  """
  def unique_payment_provider_reference,
    do: "some provider_reference#{System.unique_integer([:positive])}"

  @doc """
  Generate a payment.
  """
  def payment_fixture(attrs \\ %{}) do
    {:ok, payment} =
      attrs
      |> Enum.into(%{
        amount_minor: 42,
        currency: "some currency",
        paid_at: ~U[2026-06-24 10:02:00Z],
        provider: :mpesa,
        provider_reference: unique_payment_provider_reference(),
        raw_payload: %{},
        status: :pending
      })
      |> Kubuni.Payments.create_payment()

    payment
  end
end
