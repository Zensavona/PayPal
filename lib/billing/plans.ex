defmodule PayPal.Billing.Plans do
  @moduledoc """
  Documentation for PayPal.Billing.Plans
  """

  @doc """
  Get billing plans, no plans returns an empty list

  Possible returns:

  - {:ok, plans_list}
  - {:error, reason}

  ## Examples

      iex> PayPal.Plans.list
      {:ok,
       %{links: [%{href: "https://api.sandbox.paypal.com/v1/payments/billing-plans?page_size=10&page=0&start=1&status=CREATED",
            method: "GET", rel: "start"},
          %{href: "https://api.sandbox.paypal.com/v1/payments/billing-plans?page_size=10&page=0&status=CREATED",
            method: "GET", rel: "last"}],
         plans: [%{create_time: "2017-05-02T08:04:20.411Z",
            description: "Plan with regular and trial payment definitions.",
            id: "P-3C560437P9994340RZAYE2OY",
            links: [%{href: "https://api.sandbox.paypal.com/v1/payments/billing-plans/P-3C560437P9994340RZAYE2OY",
               method: "GET", rel: "self"}],
            name: "Plan with Regular and Trial Payment Definitions", state: "CREATED",
            type: "FIXED", update_time: "2017-05-02T08:04:20.411Z"}]}}


  """
  @spec list :: {atom, any}
  def list do
    case PayPal.API.get("payments/billing-plans") do
      {:ok, :no_content} ->
        {:ok, []}
      {:ok, :not_found} ->
        {:ok, nil}
      {:ok, data} ->
        {:ok, data}
      error ->
        error
    end
  end

  @doc """
  Create a billing plan

  [docs](https://developer.paypal.com/docs/api/payments.billing-plans#plan_create)

  This can be a bit prickly so I highly suggest you check out the official docs (above), this maps 1:1 to the HTTP API.

  Possible returns:

  - {:ok, plan}
  - {:error, reason}

  Example hash:

    %{
      name: "Plan with Regular and Trial Payment Definitions",
      description: "Plan with regular and trial payment definitions.",
      type: "FIXED",
      payment_definitions: [%{
        name: "Regular payment definition",
        type: "REGULAR",
        frequency: "MONTH",
        frequency_interval: "2",
        amount: %{
          value: "100",
          currency: "USD"
        },
        cycles: "12",
        charge_models: [
          %{
            type: "SHIPPING",
            amount: %{
              value: "10",
              currency: "USD"
            }
          },
          %{
            type: "TAX",
            amount: %{
              value: "12",
              currency: "USD"
            }
          }
        ]
      }],
      merchant_preferences: %{
        setup_fee: %{
          value: "1",
          currency: "USD"
        },
        return_url: "http://www.paypal.com",
        cancel_url: "http://www.paypal.com/cancel",
        auto_bill_amount: "YES",
        initial_fail_amount_action: "CONTINUE",
        max_fail_attempts: "0"
      }
    }


  ## Examples

      iex> PayPal.Plans.create(plan)
      {:ok, plan}


  """
  @spec create(%{
    name: String.t,
    description: String.t,
    type: String.t,
    payment_definitions: [%{
      name: String.t,
      type: String.t,
      frequency_interval: String.t,
      frequency: String.t,
      cycles: String.t,
      amount: %{
        value: String.t,
        currency: String.t
      },
      charge_models: [%{
        type: String.t,
        amount: %{
          value: String.t,
          currency: String.t
        }
      }],
      merchant_preferences: %{
        setup_fee: %{
          amount: String.t,
          currency: String.t
        },
        return_url: String.t,
        cancel_url: String.t,
        auto_bill_amount: String.t,
        initial_fail_amount_action: String.t,
        max_fail_attempts: String.t
      }
    }],
  }) :: {atom, any}
  def create(plan) do
    case PayPal.API.post("payments/billing-plans", plan) do
      {:ok, :no_content} ->
        {:ok, []}
      {:ok, :not_found} ->
        {:ok, nil}
      {:ok, data} ->
        {:ok, data}
      error ->
        error
    end
  end
end
