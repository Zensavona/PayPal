defmodule PayPal.Payments.Orders do
  @moduledoc """
  Documentation for PayPal.Payments.Orders

  https://developer.paypal.com/docs/api/payments/#order
  """

  @doc """
  Show an order

  [docs](https://developer.paypal.com/docs/api/payments/#order_get)

  Possible returns:

  - {:ok, order}
  - {:error, reason}

  ## Examples

    iex> PayPal.Payments.Orders.show(order_id)
    {:ok, order}
  """
  @spec show(String.t) :: {:ok, map | :not_found | :no_content } | {:error, :unauthorised | :bad_network | any}
  def show(order_id) do
    PayPal.API.get("payments/order/#{order_id}")
  end

  @doc """
  Authorize an order

  [docs](https://developer.paypal.com/docs/api/payments/#order_authorize)

  Possible returns:

  - {:ok, refund}
  - {:error, refund}

  ## Examples

    iex> PayPal.Payments.Orders.authorize(order_id, %{
      amount: %{
        total: "1.50",
        currency: "USD"
      }
    })
    {:ok, refund}
  """
  @spec authorize(String.t, map) :: {:ok, map | :not_found | :no_content | nil} | {:error, :unauthorised | :bad_network | any}
  def authorize(payment_id, params) do
    PayPal.API.post("payments/orders/#{payment_id}/authorize", params)
  end

  @doc """
  Capture an order

  [docs](https://developer.paypal.com/docs/api/payments/#order_capture)

  Possible returns:

  - {:ok, capture}
  - {:error, refund}

  ## Examples

    iex> PayPal.Payments.Orders.capture(order_id, %{
      amount: %{
        total: "1.50",
        currency: "USD"
      },
      is_final_capture: true
    })
    {:ok, capture}
  """
  @spec capture(String.t, map) :: {:ok, map | :not_found | :no_content} | {:error, :unauthorised | :bad_network | any}
  def capture(order_id, params) do
    PayPal.API.post("payments/orders/#{order_id}/capture", params)
  end

  @doc """
  Void an order

  [docs](https://developer.paypal.com/docs/api/payments/#order_void)

  Possible returns:

  - {:ok, order}
  - {:error, reason}

  ## Examples

    iex> PayPal.Payments.Orders.void(order_id)
    {:ok, order}
  """
  @spec void(String.t) :: {:ok, map | :not_found | :no_content} | {:error, :unauthorised | :bad_network | any}
  def void(order_id) do
    PayPal.API.post("payments/order/#{order_id}/void", nil)
  end
end
