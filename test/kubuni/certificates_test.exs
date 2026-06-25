defmodule Kubuni.CertificatesTest do
  use Kubuni.DataCase

  alias Kubuni.Certificates

  describe "certificates" do
    alias Kubuni.Certificates.Certificate

    import Kubuni.CertificatesFixtures

    @invalid_attrs %{type: nil, serial_number: nil, file_key: nil, issued_at: nil}

    test "list_certificates/0 returns all certificates" do
      certificate = certificate_fixture()
      assert Certificates.list_certificates() == [certificate]
    end

    test "get_certificate!/1 returns the certificate with given id" do
      certificate = certificate_fixture()
      assert Certificates.get_certificate!(certificate.id) == certificate
    end

    test "create_certificate/1 with valid data creates a certificate" do
      valid_attrs = %{
        type: :module,
        serial_number: "some serial_number",
        file_key: "some file_key",
        issued_at: ~U[2026-06-24 10:02:00Z]
      }

      assert {:ok, %Certificate{} = certificate} = Certificates.create_certificate(valid_attrs)
      assert certificate.type == :module
      assert certificate.serial_number == "some serial_number"
      assert certificate.file_key == "some file_key"
      assert certificate.issued_at == ~U[2026-06-24 10:02:00Z]
    end

    test "create_certificate/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Certificates.create_certificate(@invalid_attrs)
    end

    test "update_certificate/2 with valid data updates the certificate" do
      certificate = certificate_fixture()

      update_attrs = %{
        type: :course,
        serial_number: "some updated serial_number",
        file_key: "some updated file_key",
        issued_at: ~U[2026-06-25 10:02:00Z]
      }

      assert {:ok, %Certificate{} = certificate} =
               Certificates.update_certificate(certificate, update_attrs)

      assert certificate.type == :course
      assert certificate.serial_number == "some updated serial_number"
      assert certificate.file_key == "some updated file_key"
      assert certificate.issued_at == ~U[2026-06-25 10:02:00Z]
    end

    test "update_certificate/2 with invalid data returns error changeset" do
      certificate = certificate_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Certificates.update_certificate(certificate, @invalid_attrs)

      assert certificate == Certificates.get_certificate!(certificate.id)
    end

    test "delete_certificate/1 deletes the certificate" do
      certificate = certificate_fixture()
      assert {:ok, %Certificate{}} = Certificates.delete_certificate(certificate)
      assert_raise Ecto.NoResultsError, fn -> Certificates.get_certificate!(certificate.id) end
    end

    test "change_certificate/1 returns a certificate changeset" do
      certificate = certificate_fixture()
      assert %Ecto.Changeset{} = Certificates.change_certificate(certificate)
    end
  end
end
