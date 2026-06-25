defmodule Kubuni.PaymentsTest do
  use Kubuni.DataCase

  alias Kubuni.Payments

  describe "payments" do
    alias Kubuni.Payments.Payment

    import Kubuni.PaymentsFixtures

    @invalid_attrs %{
      status: nil,
      currency: nil,
      provider: nil,
      provider_reference: nil,
      amount_minor: nil,
      raw_payload: nil,
      paid_at: nil
    }

    test "list_payments/0 returns all payments" do
      payment = payment_fixture()
      assert Payments.list_payments() == [payment]
    end

    test "get_payment!/1 returns the payment with given id" do
      payment = payment_fixture()
      assert Payments.get_payment!(payment.id) == payment
    end

    test "create_payment/1 with valid data creates a payment" do
      valid_attrs = %{
        status: :pending,
        currency: "some currency",
        provider: :mpesa,
        provider_reference: "some provider_reference",
        amount_minor: 42,
        raw_payload: %{},
        paid_at: ~U[2026-06-24 10:02:00Z]
      }

      assert {:ok, %Payment{} = payment} = Payments.create_payment(valid_attrs)
      assert payment.status == :pending
      assert payment.currency == "some currency"
      assert payment.provider == :mpesa
      assert payment.provider_reference == "some provider_reference"
      assert payment.amount_minor == 42
      assert payment.raw_payload == %{}
      assert payment.paid_at == ~U[2026-06-24 10:02:00Z]
    end

    test "create_payment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_payment(@invalid_attrs)
    end

    test "update_payment/2 with valid data updates the payment" do
      payment = payment_fixture()

      update_attrs = %{
        status: :successful,
        currency: "some updated currency",
        provider: :paystack,
        provider_reference: "some updated provider_reference",
        amount_minor: 43,
        raw_payload: %{},
        paid_at: ~U[2026-06-25 10:02:00Z]
      }

      assert {:ok, %Payment{} = payment} = Payments.update_payment(payment, update_attrs)
      assert payment.status == :successful
      assert payment.currency == "some updated currency"
      assert payment.provider == :paystack
      assert payment.provider_reference == "some updated provider_reference"
      assert payment.amount_minor == 43
      assert payment.raw_payload == %{}
      assert payment.paid_at == ~U[2026-06-25 10:02:00Z]
    end

    test "update_payment/2 with invalid data returns error changeset" do
      payment = payment_fixture()
      assert {:error, %Ecto.Changeset{}} = Payments.update_payment(payment, @invalid_attrs)
      assert payment == Payments.get_payment!(payment.id)
    end

    test "delete_payment/1 deletes the payment" do
      payment = payment_fixture()
      assert {:ok, %Payment{}} = Payments.delete_payment(payment)
      assert_raise Ecto.NoResultsError, fn -> Payments.get_payment!(payment.id) end
    end

    test "change_payment/1 returns a payment changeset" do
      payment = payment_fixture()
      assert %Ecto.Changeset{} = Payments.change_payment(payment)
    end
  end
end
