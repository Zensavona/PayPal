defmodule PayPal.Payments.Sales do
  @moduledoc """
  Documentation for PayPal.Payments.Sales

  A sale is a completed payment.

  https://developer.paypal.com/docs/api/payments/#sale
  """

  @doc """
  Show a sale

  [docs](https://developer.paypal.com/docs/api/payments/#sale_get)

  Possible returns:

  - {:ok, sale}
  - {:error, reason}

  ## Examples

    iex> PayPal.Payments.Sales.show(sale_id)
    {:ok, payment}
  """
  @spec show(String.t) :: {:ok, map | :not_found | :no_content } | {:error, :unauthorised | :bad_network | any}
  def show(sale_id) do
    PayPal.API.get("payments/sale/#{sale_id}")
  end

  @doc """
  Refund a sale

  [docs](https://developer.paypal.com/docs/api/payments/#sale_refund)

  Possible returns:

  - {:ok, sale}
  - {:error, refund}

  ## Examples

    iex> PayPal.Payments.Sales.refund(sale_id, %{
      amount: %{
        total: "1.50",
        currency: "USD"
      }
    })
    {:ok, payment}
  """
  @spec refund(String.t, map) :: {:ok, map | :not_found | :no_content | nil} | {:error, :unauthorised | :bad_network | any}
  def refund(sale_id, params) do
    PayPal.API.post("payments/sale/#{sale_id}/refund", params)
  end
end
