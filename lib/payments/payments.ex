defmodule PayPal.Payments.Payments do
  @moduledoc """
  Documentation for PayPal.Payments.Payments
  """

  @doc """
  Create a payment

  [docs](https://developer.paypal.com/docs/api/payments/#payment_create)

  This can be a bit prickly so I highly suggest you check out the official docs (above), this maps 1:1 to the HTTP API.

  Possible returns:

  - {:ok, payment}
  - {:error, reason}

  ## Examples

    iex> PayPal.Payments.Payments.create(%{
      intent: "sale",
      payer: %{
        payment_method: "paypal"
      },
      transactions: [%{
        amount: %{
          total: "30.11",
          currency: "USD",
          details: %{
            subtotal: "30.00",
            tax: "0.07",
            shipping: "0.03",
            handling_fee: "1.00",
            shipping_discount: "-1.00",
            insurance: "0.01"
          }
        },
        description: "The payment transaction description.",
        custom: "EBAY_EMS_90048630024435",
        invoice_number: "48787589673",
        payment_options: %{
          allowed_payment_method: "INSTANT_FUNDING_SOURCE"
        },
        soft_descriptor: "ECHI5786786",
        item_list: %{
          items: [%{
            name: "hat",
            description: "Brown hat.",
            quantity: "5",
            price: "3",
            tax: "0.01",
            sku: "1",
            currency: "USD"
          },
          %{
            name: "handbag",
            description: "Black handbag.",
            quantity: "1",
            price: "15",
            tax: "0.02",
            sku: "product34",
            currency: "USD"
          }],
          shipping_address: %{
            recipient_name: "Brian Robinson",
            line1: "4th Floor",
            line2: "Unit #34",
            city: "San Jose",
            country_code: "US",
            postal_code: "95131",
            phone: "011862212345678",
            state: "CA"
          }
        }
      }
      ],
      note_to_payer: "Contact us for any questions on your order.",
      redirect_urls: %{
        return_url: "http://www.paypal.com/return",
        cancel_url: "http://www.paypal.com/cancel"
      }
    })
    {:ok, %{
      id: "PAY-1B56960729604235TKQQIYVY",
      create_time: "2017-09-22T20:53:43Z",
      update_time: "2017-09-22T20:53:44Z",
      state: "created",
      intent: "sale",
      payer: %{
        payment_method: "paypal"
      },
      transactions: [
        %{
          amount: %{
            total: "30.11",
            currency: "USD",
            details: %{
              subtotal: "30.00",
              tax: "0.07",
              shipping: "0.03",
              handling_fee: "1.00",
              insurance: "0.01",
              shipping_discount: "-1.00"
            }
          },
          description: "The payment transaction description.",
          custom: "EBAY_EMS_90048630024435",
          invoice_number: "48787589673",
          item_list: %{
            items: [
              %{
                name: "hat",
                sku: "1",
                price: "3.00",
                currency: "USD",
                quantity: "5",
                description: "Brown hat.",
                tax: "0.01"
              },
              %{
                name: "handbag",
                sku: "product34",
                price: "15.00",
                currency: "USD",
                quantity: "1",
                description: "Black handbag.",
                tax: "0.02"
              }
            ],
            shipping_address: %{
              recipient_name: "Brian Robinson",
              line1: "4th Floor",
              line2: "Unit #34",
              city: "San Jose",
              state: "CA",
              phone: "011862212345678",
              postal_code: "95131",
              country_code: "US"
            }
          }
        }
      ],
      links: [
        %{
          href: "https://api.sandbox.paypal.com/v1/payments/payment/PAY-1B56960729604235TKQQIYVY",
          rel: "self",
          method: "GET"
        },
        %{
          href: "https://api.sandbox.paypal.com/v1/payments//cgi-bin/webscr?cmd=_express-checkout&token=EC-60385559L1062554J",
          rel: "approval_url",
          method: "REDIRECT"
        },
        %{
          href: "https://api.sandbox.paypal.com/v1/payments/payment/PAY-1B56960729604235TKQQIYVY/execute",
          rel: "execute",
          method: "POST"
        }
      ]
    }}

  """
  @spec create(map) :: {:ok, map} | {:ok, :not_found} | {:ok, :no_content} | {:error, :unauthorised} | {:error, :bad_network} | {:error, any}
  def create(payment) do
    PayPal.API.post("payments/payment", payment)
  end

  @doc """
  Execute an approved PayPal payment

  [docs](https://developer.paypal.com/docs/api/payments/#payment_execute)

  Possible returns:

  - {:ok, payment}
  - {:error, reason}

  ## Examples

    iex> PayPal.Payments.Payments.execute(payment_id, payer_id)
    {:ok, payment}
  """
  @spec execute(String.t, String.t) :: {:ok, map} | {:ok, :not_found} | {:ok, :no_content} | {:error, :unauthorised} | {:error, :bad_network} | {:error, any}
  def execute(payment_id, payer_id) do
    PayPal.API.post("payments/payment/#{payment_id}/execute", %{payer_id: payer_id})
  end

  @doc """
  Show a payment

  [docs](https://developer.paypal.com/docs/api/payments/#payment_get)

  Possible returns:

  - {:ok, payment}
  - {:error, reason}

  ## Examples

    iex> PayPal.Payments.Payments.show(payment_id)
    {:ok, payment}
  """
  @spec show(String.t) :: {:ok, map} | {:ok, :not_found} | {:ok, :no_content} | {:error, :unauthorised} | {:error, :bad_network} | {:error, any}
  def show(payment_id) do
    PayPal.API.get("payments/payment/#{payment_id}")
  end

  @doc """
  Update a payment

  [docs](https://developer.paypal.com/docs/api/payments/#payment_update)

  This can be a bit prickly so I highly suggest you check out the official docs (above), this maps 1:1 to the HTTP API.

  This function takes an ID and a list of change operations (see the PayPal API docs, this is kind of a pain in the ass)

  Possible returns:

  - {:ok, payment}
  - {:error, reason}

  ## Examples

    iex> PayPal.Payments.Payments.update(payment_id, [%{
      op: "replace",
      path: "/transactions/0/amount",
      value: %{
        total: "18.37",
        currency: "EUR",
        details: %{
          subtotal: "13.37",
          shipping: "5.00"
        }
      }
    },
    %{
      op: "add",
      path: "/transactions/0/item_list/shipping_address",
      value: %{
        recipient_name: "Anna Gruneberg",
        line1: "Kathwarinenhof 1",
        city: "Flensburg",
        postal_code: "24939",
        country_code: "DE"
      }
    }])
    {:ok, payment}

  """
  @spec update(String.t, list) :: {:ok, map} | {:ok, nil} | {:ok, :not_found} | {:ok, :no_content} | {:error, :unauthorised} | {:error, :bad_network} | {:error, any}
  def update(payment_id, changes) do
    PayPal.API.patch("payments/payment/#{payment_id}", changes)
  end

  @doc """
  Get a list of all payments

  [docs](https://developer.paypal.com/docs/api/payments/#payment_list)

  Possible returns:

  - {:ok, payments}
  - {:error, reason}

  ## Examples

    iex> PayPal.Payments.Payments.show(%{count: 10})
    {:ok, payment}
  """
  @spec list(map) :: {:ok, [map]} | {:ok, map} | {:ok, :not_found} | {:ok, :no_content} | {:error, :unauthorised} | {:error, :bad_network} | {:error, any}
  def list(query \\ %{}) do
    case PayPal.API.get("payments/payment?#{URI.encode_query(query)}") do
      {:ok, %{payments: payments}} ->
        {:ok, payments}
      error ->
        error
    end
  end
end
