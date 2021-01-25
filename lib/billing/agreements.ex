defmodule PayPal.Billing.Agreements do
  @moduledoc """
  Documentation for PayPal.Billing.Agreements
  """
  @doc """
  Create a billing agreement

  [docs](https://developer.paypal.com/docs/api/payments.billing-agreements#agreement_create)

  This can be a bit prickly so I highly suggest you check out the official docs (above), this maps 1:1 to the HTTP API.

  Possible returns:

  - {:ok, agreement}
  - {:error, reason}

  Example hash:

  %{
    name: "Magazine Subscription",
    description: "Monthly subscription with a regular monthly payment definition and two-month trial payment definition.",
    start_date: "2017-12-22T09:13:49Z",
    plan: %{
      id: "plan_id"
    },
    payer: %{
      payment_method: "paypal"
    },
    shipping_address: %{
      line1: "751235 Stout Drive",
      line2: "0976249 Elizabeth Court",
      city: "Quimby",
      state: "IA",
      postal_code: "51049",
      country_code: "US"
    }
  }


  ## Examples

      iex> PayPal.Billing.Agreements.create(plan)
      {:ok, plan}


  """
  @spec create(%{
    name: String.t,
    description: String.t,
    start_date: String.t,
    plan: %{
      id: String.t
    },
    payer: %{
      payment_method: String.t
    },
    shipping_address: %{
      line1: String.t,
      line2: String.t,
      city: String.t,
      state: String.t,
      postal_code: String.t,
      country_code: String.t
    }
  }) :: {:ok, map | :not_found | :no_content | nil} | {:error, :unauthorised | :bad_network | any}
  def create(agreement) do
    case PayPal.API.post("payments/billing-agreements", agreement) do
      {:ok, data} ->
        {:ok, data}
      error ->
        error
    end
  end

  @doc """
  Execute a billing agreement

  [docs](https://developer.paypal.com/docs/api/payments.billing-agreements#agreement_execute)

  This can be a bit prickly so I highly suggest you check out the official docs (above), this maps 1:1 to the HTTP API.

  Possible returns:

  - {:ok, agreement}
  - {:error, reason}

  ## Examples

      iex> PayPal.Billing.Agreements.execute(agreement_id)
      {:ok, plan}
  """
  @spec execute(String.t) :: {:ok, map | :not_found | :no_content | nil} | {:error, :unauthorised | :bad_network | any}
  def execute(agreement_id) do
    case PayPal.API.post("payments/billing-agreements/#{agreement_id}/agreement-execute", nil) do
      {:ok, data} ->
        {:ok, data}
      error ->
        error
    end
  end

  @doc """
  Update a billing agreement

  [docs](https://developer.paypal.com/docs/api/payments.billing-agreements#agreement_update)

  This can be a bit prickly so I highly suggest you check out the official docs (above), this maps 1:1 to the HTTP API.

  This function takes an ID and a list of change operations (see the PayPal API docs, this is kind of a pain in the ass)

  Possible returns:

  - {:ok, plan}
  - {:error, reason}

  Example list of operations:

  [
    %{
      op: "replace",
      path: "/",
      value: %{
        start_date: "2017-12-22T09:13:49Z"
      }
    }
  ]


  ## Examples

      iex> PayPal.Billing.Agreements.update(id, plan)
      {:ok, plan}


  """
  @spec update(String.t, map) :: {:ok, map | nil | :not_found | :no_content} | {:error, :unauthorised | :bad_network | any}
  def update(id, plan) do
    case PayPal.API.patch("payments/billing-agreements/#{id}", plan) do
      {:ok, data} ->
        {:ok, data}
      error ->
        error
    end
  end

  @doc """
  Get a billing agreement by ID.

  Possible returns:

  - {:ok, plan}
  - {:ok, nil}
  - {:error, reason}

  ## Examples

      iex> PayPal.Billing.Agreements.show(id)
      {:ok,
          %{create_time: "2017-05-02T08:04:20.411Z",
            description: "Plan with regular and trial payment definitions.",
            id: "P-3C560437P9994340RZAYE2OY",
            links: [%{href: "https://api.sandbox.paypal.com/v1/payments/billing-plans/P-3C560437P9994340RZAYE2OY",
               method: "GET", rel: "self"}],
            name: "Plan with Regular and Trial Payment Definitions", state: "CREATED",
            type: "FIXED", update_time: "2017-05-02T08:04:20.411Z"}}

  """
  @spec show(String.t) :: {:ok, map | :not_found | :no_content } | {:error, :unauthorised | :bad_network | any}
  def show(id) do
    case PayPal.API.get("payments/billing-agreements/#{id}") do
      {:ok, :not_found} ->
        {:ok, nil}
      {:ok, agreement} ->
        {:ok, agreement}
      error ->
        error
    end
  end

  @doc """
  Cancel a billing agreement

  [docs](https://developer.paypal.com/docs/api/payments.billing-agreements#agreement_cancel)

  Possible returns:

  - {:ok, nil}
  - {:error, reason}

  ## Examples

      iex> PayPal.Billing.Agreements.cancel(agreement_id, note)
      {:ok, nil}


  """
  @spec cancel(String.t, String.t) :: {:ok, map | :not_found | :no_content | nil} | {:error, :unauthorised | :bad_network | any}
  def cancel(agreement_id, note) do
    case PayPal.API.post("payments/billing-agreements/#{agreement_id}/cancel", %{note: note}) do
      {:ok, data} ->
        {:ok, data}
      error ->
        error
    end
  end

  @doc """
  Bill the balance for an agreement

  [docs](https://developer.paypal.com/docs/api/payments.billing-agreements#agreement_bill-balance)

  Possible returns:

  - {:ok, nil}
  - {:error, reason}

  ## Examples

      iex> PayPal.Billing.Agreements.bill_balance(agreement_id, %{note: "something", amount: %{ value: "10", currency: "AUD"}})
      {:ok, nil}


  """
  @spec bill_balance(String.t, map) :: {:ok, map | :not_found | :no_content | nil} | {:error, :unauthorised | :bad_network | any}
  def bill_balance(agreement_id, params) do
    case PayPal.API.post("payments/billing-agreements/#{agreement_id}/bill-balance", params) do
      {:ok, data} ->
        {:ok, data}
      error ->
        error
    end
  end

  @doc """
  Set the agreement balance

  [docs](https://developer.paypal.com/docs/api/payments.billing-agreements#agreement_set-balance)

  Possible returns:

  - {:ok, nil}
  - {:error, reason}

  ## Examples

      iex> PayPal.Billing.Agreements.set_balance(agreement_id, %{value: "10", currency: "AUD"})
      {:ok, nil}


  """
  @spec set_balance(String.t, map) :: {:ok, map | :not_found | :no_content | nil} | {:error, :unauthorised | :bad_network | any}
  def set_balance(agreement_id, params) do
    case PayPal.API.post("payments/billing-agreements/#{agreement_id}/set-balance", params) do
      {:ok, data} ->
        {:ok, data}
      error ->
        error
    end
  end

  @doc """
  Reactivate an agreement

  [docs](https://developer.paypal.com/docs/api/payments.billing-agreements#agreement_re-activate)

  Possible returns:

  - {:ok, nil}
  - {:error, reason}

  ## Examples

      iex> PayPal.Billing.Agreements.reactivate(agreement_id, "some reason")
      {:ok, nil}


  """
  @spec reactivate(String.t, String.t) :: {:ok, map | :not_found | :no_content | nil} | {:error, :unauthorised | :bad_network | any}
  def reactivate(agreement_id, note) do
    case PayPal.API.post("payments/billing-agreements/#{agreement_id}/re-activate", %{note: note}) do
      {:ok, data} ->
        {:ok, data}
      error ->
        error
    end
  end

  @doc """
  Suspend an agreement

  [docs](https://developer.paypal.com/docs/api/payments.billing-agreements#agreement_suspend)

  Possible returns:

  - {:ok, nil}
  - {:error, reason}

  ## Examples

      iex> PayPal.Billing.Agreements.suspend(agreement_id, "some reason")
      {:ok, nil}


  """
  @spec suspend(String.t, String.t) :: {:ok, map | :not_found | :no_content | nil} | {:error, :unauthorised | :bad_network | any}
  def suspend(agreement_id, note) do
    case PayPal.API.post("payments/billing-agreements/#{agreement_id}/suspend", %{note: note}) do
      {:ok, data} ->
        {:ok, data}
      error ->
        error
    end
  end

  @doc """
  List the agreement's transactions

  [docs](https://developer.paypal.com/docs/api/payments.billing-agreements#agreement_transactions)

  Possible returns:

  - {:ok, transactions}
  - {:ok, :not_found}
  - {:error, reason}

  ## Examples

      iex> PayPal.Billing.Agreements.transactions(agreement_id, "2017-06-15", "2017-06-17")
      {:ok, [
              {
                "transaction_id": "I-V8SSE9WLJGY6",
                "status": "Created",
                "transaction_type": "Recurring Payment",
                "amount": {
                  "value": "100",
                  "currency": "USD"
                },
                "fee_amount": {
                  "value": "1",
                  "currency": "USD"
                },
                "net_amount": {
                  "value": "100",
                  "currency": "USD"
                },
                "payer_email": "",
                "payer_name": " ",
                "time_stamp": "2017-06-16T13:46:53Z",
                "time_zone": "GMT"
              }]}
  """
  @spec transactions(String.t, String.t, String.t) :: {:ok, map | :not_found | :no_content } | {:error, :unauthorised | :bad_network | any}
  def transactions(agreement_id, start_date, end_date) do
    case PayPal.API.get("payments/billing-agreements/#{agreement_id}/transactions?start_date=#{start_date}&end_date=#{end_date}") do
      {:ok, %{agreement_transaction_list: data}} ->
        {:ok, data}
      error ->
        error
    end
  end
end
