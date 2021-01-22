defmodule PayPal.Payments.Payouts do
  @moduledoc """
  Documentation for PayPal.Payouts.Payouts

  https://developer.paypal.com/docs/api/payments.payouts-batch/v1/#payouts
  """

  @doc """
  Create batch payout

  [docs](https://developer.paypal.com/docs/api/payments.payouts-batch/v1/#payouts_post)

  Possible returns:

  - {:ok, batch_header}
  - {:error, reason}

  ## Parameters
    - batch_header: Map with the values for the batch header
    - items: list of maps, each representing a Payout within the batch

  ## Examples
    iex> batch_header = %{ "sender_batch_id" => "Payouts_20200805",
                            "email_subject" => "You have a payout!",
                            "email_message" => "You have received a payout! Thanks for using our service!"
                          }
    iex> items = [ %{ "recipient_type" => "EMAIL",
                      "amount" => %{
                        "value" => "9.87",
                        "currency" => "USD"
                      },
                      "note" => "Thanks for your patronage!",
                      "sender_item_id" => "201403140001",
                      "receiver" => "receiver@example.com"
              }]
    iex> PayPal.Payments.Payouts.create_batch(batch_header, items)
    {:ok, batch_response}
  """
  @spec create_batch(map, nonempty_list(map)) :: {:ok, map} | {:ok, :not_found} | {:ok, :no_content} | {:error, :unauthorised} | {:error, :bad_network} | {:error, any}
  def create_batch(batch_header, items) when is_map(batch_header) and is_list(items) do
    PayPal.API.post("payments/payouts", %{"sender_batch_header" => batch_header, "items" => items})
  end

  @doc """
  Get latest status of a batch payout.

  [docs](https://developer.paypal.com/docs/api/payments.payouts-batch/v1/#payouts_get)

  Possible returns:
  - {:ok, payout_batch}
  - {:error, reason}

  ## Parameters
  - payout_batch_id: the PayPal id assigned to the batch (binary)

  ## Examples
    iex> PayPal.Payments.Payouts.payouts_get("FYXMPQTX4JC9N")
    {:ok, %{
        "batch_header" => %{
          "payout_batch_id" => "FYXMPQTX4JC9N",
          "batch_status" => "PROCESSING",
          "time_created" => "2014-01-27T10:17:00Z",
          "time_completed" => "2014-01-27T11:17:39.00Z",
          "sender_batch_header" => {
            "sender_batch_id" => "Payouts_2018_100009",
            "email_subject" => "You have a payout!"
          },
          "amount" => %{
            "value" => "125.11",
            "currency" => "USD"
          },
          "fees" => %{
            "value" => "2.00",
            "currency" => "USD"
          }
        },
        "items" => %[
          %{
            "payout_item_id" => "DUCD8GC3VUKVE",
            "transaction_id" => "6KA23440H1057442S",
            "transaction_status" => "SUCCESS",
            "payout_batch_id" => "FYXMPQTX4JC9N",
            "payout_item_fee" => {
              "currency" => "USD",
              "value" => "1.00"
            },
            "payout_item" => %{
              "recipient_type" => "EMAIL",
              "amount" => %{
                "value" => "65.24",
                "currency" => "USD"
              },
              "note" => "Thanks for your patronage!",
              "receiver" => "receiver@example.com",
              "sender_item_id" => "14Feb_978"
            },
            "time_processed" => "2014-01-27T10:18:32Z"
          },
          %{
            "payout_item_id" => "LGMEPRKTK7FQA",
            "transaction_id" => "8K128187J1102003K",
            "transaction_status" => "SUCCESS",
            "payout_batch_id" => "FYXMPQTX4JC9N",
            "payout_item_fee" => %{
              "currency" => "USD",
              "value" => "1.00"
            },
            "payout_item" => %{
              "recipient_type" => "EMAIL",
              "amount" => %{
                "value" => "59.87",
                "currency" => "USD"
              },
              "note" => "Thanks for your patronage!",
              "receiver" => "receiver2@example.com",
              "sender_item_id" => "14Feb_321"
            },
            "time_processed" => "2014-01-27T10:18:15Z"
          }
        ],
        "links" => [
          %{
            "rel" => "self",
            "href" => "https://api.sandbox.paypal.com/v1/payments/payouts/FYXMPQTX4JC9N?page_size=1000&page=1",
            "method" => "GET"
          }
        ]
      }
  """
  @spec get_payouts_batch(binary) :: {:ok, map} | {:ok, :not_found} | {:ok, :no_content} | {:error, :unauthorised} | {:error, :bad_network} | {:error, any}
  def get_payouts_batch(payout_batch_id) when is_binary(payout_batch_id) do
    PayPal.API.get("payments/payouts/#{payout_batch_id}")
  end

  @doc """
  Gets details of one Payout item

  [docs](https://developer.paypal.com/docs/api/payments.payouts-batch/v1/#payouts-item_get)

  Possible returns:
    - {:ok, payout_details}
    - {:error, reason}

  ## Parameters
    - payout_id: the PayPal id assigned to the individual Payout (binary)

  ## Examples
  iex> PayPal.Payments.Payouts.get_payout(8AELMXH8UB2P8)
  {:ok,
    %{
      "payout_item_id" => "8AELMXH8UB2P8",
      "transaction_id" => "0C413693MN970190K",
      "activity_id" => "0E158638XS0329106",
      "transaction_status" => "SUCCESS",
      "payout_item_fee" => %{
        "currency" => "USD",
        "value" => "0.35"
      },
      "payout_batch_id" => "Q8KVJG9TZTNN4",
      "payout_item" => %{
        "amount" => %{
          "value" => "9.87",
          "currency" => "USD"
        },
        "recipient_type" => "EMAIL",
        "note" => "Thanks for your patronage!",
        "receiver" => "receiver@example.com",
        "sender_item_id" => "14Feb_234"
      },
      "time_processed" => "2018-01-27T10:17:41Z",
      "links" => [
        %{
          "rel" => "self",
          "href" => "https://api.sandbox.paypal.com/v1/payments/payouts-item/8AELMXH8UB2P8",
          "method" => "GET"
        },
        %{
          "href" => "https://api.sandbox.paypal.com/v1/payments/payouts/Q8KVJG9TZTNN4",
          "rel" => "batch",
          "method" => "GET"
        }
      ]
    }
  }
  """
  @spec get_payout(binary) :: {:ok, map} | {:ok, :not_found} | {:ok, :no_content} | {:error, :unauthorised} | {:error, :bad_network} | {:error, any}
  def get_payout(payout_id) when is_binary(payout_id) do
    PayPal.API.get("payments/payouts-item/#{payout_id}")
  end

  @doc """
  Cancels an unclaimed payout

  [docs](https://developer.paypal.com/docs/api/payments.payouts-batch/v1/#payouts-item-cancel-path-parameters)

  Possible returns:
    - {:ok, payout_details}
    - {:error, reason}

  ## Parameters
    - payout_id: the PayPal-assigned id for the unclaimed payout to be canceled (binary)

  ## Examples
    iex> Paypal.Payments.Payouts.cancel("5KUDKLF8SDC7S")
    {:ok,
      %{
        "payout_item_id" => "5KUDKLF8SDC7S",
        "transaction_id" => "1DG93452WK758815H",
        "activity_id" => "0E158638XS0329101",
        "transaction_status" => "RETURNED",
        "payout_item_fee" => %{
          "currency" => "USD",
          "value" => "0.35"
        },
        "payout_batch_id" => "CQMWKDQF5GFLL",
        "sender_batch_id" => "Payouts_2018_100006",
        "payout_item" => %{
          "recipient_type" => "EMAIL",
          "amount" => %{
            "value" => "9.87",
            "currency" => "USD"
          },
          "note" => "Thanks for your patronage!",
          "receiver" => "receiver@example.com",
          "sender_item_id" => "14Feb_234"
        },
        "time_processed" => "2018-01-27T10:17:41Z",
        "errors" => %{
          "name" => "RECEIVER_UNREGISTERED",
          "message" => "Receiver is unregistered",
          "information_link" => "https://developer.paypal.com/docs/api/payments.payouts-batch#errors"
        },
        "links" => [
          %{
            "rel" => "self",
            "href" => "https://api.sandbox.paypal.com/v1/payments/payouts-item/5KUDKLF8SDC7S",
            "method" => "GET"
          },
          %{
            "rel" => "batch",
            "href" => "https://api.sandbox.paypal.com/v1/payments/payouts/CQMWKDQF5GFLL",
            "method" => "GET"
          }
        ]
      }
    }
  """
  @spec cancel(binary) :: {:ok, map} | {:ok, :not_found} | {:ok, :no_content} | {:error, :unauthorised} | {:error, :bad_network} | {:error, any}
  def cancel(payout_id) when is_binary(payout_id) do
    PayPal.API.post("payments/payouts-item/#{payout_id}/cancel", %{})
  end
end