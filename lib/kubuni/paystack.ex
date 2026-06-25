defmodule Kubuni.Paystack do
  @moduledoc """
  Paystack hosted-checkout adapter.
  """

  @behaviour Kubuni.Payments.Provider

  alias Kubuni.Payments.Payment

  @impl true
  def initiate(%Payment{} = payment) do
    payment = Kubuni.Repo.preload(payment, :user)

    request(:post, "/transaction/initialize",
      json: %{
        email: payment.user.email,
        amount: payment.amount_minor,
        reference: payment.provider_reference,
        callback_url: callback_url()
      }
    )
    |> normalize_response()
  end

  @impl true
  def verify(reference) when is_binary(reference) do
    request(:get, "/transaction/verify/#{URI.encode(reference)}")
    |> normalize_response()
  end

  def callback_url do
    Application.fetch_env!(:kubuni, :paystack_callback_url)
  end

  defp request(method, path, options \\ []) do
    Req.request(
      [
        method: method,
        url: api_url() <> path,
        headers: [
          {"authorization", "Bearer #{secret_key()}"},
          {"content-type", "application/json"}
        ],
        retry: :transient,
        max_retries: 2,
        receive_timeout: 15_000
      ] ++ options
    )
  end

  defp normalize_response({:ok, %{status: status, body: %{"status" => true, "data" => data}}})
       when status in 200..299,
       do: {:ok, data}

  defp normalize_response({:ok, %{body: body}}) when is_map(body),
    do: {:error, Map.get(body, "message", "Paystack request failed")}

  defp normalize_response({:ok, %{status: status}}),
    do: {:error, {:unexpected_paystack_response, status}}

  defp normalize_response({:error, reason}), do: {:error, reason}

  defp api_url, do: Application.fetch_env!(:kubuni, :paystack_api_url)

  defp secret_key do
   "sk_test_7267bf7b9b38cd9798c6328f7e0b3cc5a264f4aa"
  end
end
