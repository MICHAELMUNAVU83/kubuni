defmodule Kubuni.CertificatesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Kubuni.Certificates` context.
  """

  @doc """
  Generate a unique certificate serial_number.
  """
  def unique_certificate_serial_number,
    do: "some serial_number#{System.unique_integer([:positive])}"

  @doc """
  Generate a certificate.
  """
  def certificate_fixture(attrs \\ %{}) do
    {:ok, certificate} =
      attrs
      |> Enum.into(%{
        file_key: "some file_key",
        issued_at: ~U[2026-06-24 10:02:00Z],
        serial_number: unique_certificate_serial_number(),
        type: :module
      })
      |> Kubuni.Certificates.create_certificate()

    certificate
  end
end
