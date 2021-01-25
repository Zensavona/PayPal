defmodule PayPal.Payments.Authorizations do
  @moduledoc """
  Documentation for PayPal.Payments.Authorizations

  https://developer.paypal.com/docs/api/payments/#authorization
  """

  @doc """
  Show an authorization

  [docs](https://developer.paypal.com/docs/api/payments/#authorization_get)

  Possible returns:

  - {:ok, authorization}
  - {:error, reason}

  ## Examples

    iex> PayPal.Payments.Authorizations.show(authorization_id)
    {:ok, authorization}
  """
  @spec show(String.t) :: {:ok, map | :not_found | :no_content } | {:error, :unauthorised | :bad_network | any}
  def show(authorization_id) do
    PayPal.API.get("payments/authorization/#{authorization_id}")
  end

  @doc """
  Capture an authorization

  [docs](https://developer.paypal.com/docs/api/payments/#authorization_capture)

  Possible returns:

  - {:ok, capture}
  - {:error, reason}

  ## Examples

    iex> PayPal.Payments.Authorizations.capture(authorization_id, %{
      amount: %{
        currency: "USD",
        amount: "4.54"
      },
      is_final_capture: true
    })
    {:ok, capture}
  """
  @spec capture(String.t, map) :: {:ok, map | :not_found | :no_content | nil} | {:error, :unauthorised | :bad_network | any}
  def capture(authorization_id, params) do
    PayPal.API.post("payments/authorization/#{authorization_id}/capture", params)
  end

  @doc """
  Void an authorization

  [docs](https://developer.paypal.com/docs/api/payments/#authorization_void)

  Possible returns:

  - {:ok, authorization}
  - {:error, reason}

  ## Examples

    iex> PayPal.Payments.Authorizations.void(authorization_id)
    {:ok, authorization}
  """
  @spec void(String.t) :: {:ok, map | :not_found | :no_content | nil} | {:error, :unauthorised | :bad_network | any}
  def void(authorization_id) do
    PayPal.API.post("payments/authorization/#{authorization_id}/void", nil)
  end

  @doc """
  Reauthorize a payment

  [docs](https://developer.paypal.com/docs/api/payments/#authorization_reauthorize)

  Possible returns:

  - {:ok, authorization}
  - {:error, reason}

  ## Examples

    iex> PayPal.Payments.Authorizations.capture(authorization_id, %{
      amount: %{
        currency: "USD",
        amount: "4.54"
      }
    })
    {:ok, authorization}
  """
  @spec reauthorize(String.t, map) :: {:ok, map | :not_found | :no_content | nil} | {:error, :unauthorised | :bad_network | any}
  def reauthorize(authorization_id, params) do
    PayPal.API.post("payments/authorization/#{authorization_id}/reauthorize", params)
  end
end
