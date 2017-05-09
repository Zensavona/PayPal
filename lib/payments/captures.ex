defmodule PayPal.Payments.Captures do
  @moduledoc """
  Documentation for PayPal.Payments.Captures

  https://developer.paypal.com/docs/api/payments/#capture
  """

  @doc """
  Show a captured payment

  [docs](https://developer.paypal.com/docs/api/payments/#capture_get)

  Possible returns:

  - {:ok, capture}
  - {:error, reason}

  ## Examples

    iex> PayPal.Payments.Captures.show(capture_id)
    {:ok, capture}
  """
  @spec show(String.t) :: {atom, any}
  def show(capture_id) do
    PayPal.API.get("payments/capture/#{capture_id}")
  end

  @doc """
  Refund a captured payment

  [docs](https://developer.paypal.com/docs/api/payments/#capture_refund)

  Possible returns:

  - {:ok, refund}
  - {:error, refund}

  ## Examples

    iex> PayPal.Payments.Captures.refund(payment_id, %{
      amount: %{
        total: "1.50",
        currency: "USD"
      }
    })
    {:ok, refund}
  """
  @spec refund(String.t, map) :: {atom, any}
  def refund(payment_id, params) do
    PayPal.API.post("payments/capture/#{payment_id}/refund", params)
  end
end
