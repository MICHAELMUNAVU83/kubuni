defmodule KubuniWeb.CertificateController do
  use KubuniWeb, :controller

  alias Kubuni.Certificates

  def download(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    certificate = Certificates.get_user_certificate!(user, id)

    case Certificates.download_url(user, certificate) do
      {:ok, url} -> redirect(conn, external: url)
      {:error, _reason} -> send_resp(conn, :service_unavailable, "Certificate unavailable")
    end
  end
end
