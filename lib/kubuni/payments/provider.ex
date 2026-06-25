defmodule Kubuni.Payments.Provider do
  @moduledoc """
  Boundary for hosted payment providers.
  """

  alias Kubuni.Payments.Payment

  @callback initiate(Payment.t()) :: {:ok, map()} | {:error, term()}
  @callback verify(String.t()) :: {:ok, map()} | {:error, term()}
end
