defmodule PayPalPayoutsTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes", "fixture/custom_cassettes")
    ExVCR.Config.filter_url_params(true)
    ExVCR.Config.response_headers_blacklist(["paypal-debug-id", "Paypal-Debug-Id", "Set-Cookie"])
    ExVCR.Config.filter_request_headers("Authorization")
    ExVCR.Config.filter_sensitive_data("basic_auth\" =>\".+?\"", "basic_auth\" =>\"<REMOVED>\"")
    ExVCR.Config.filter_sensitive_data("app_id\" =>\".+?\"", "app_id\" =>\"<REMOVED>\"")
    ExVCR.Config.filter_sensitive_data("access_token\" =>\".+?\"", "access_token\" =>\"<REMOVED>\"")
    :ok
  end

  test "create a payout batch" do
    use_cassette "payouts_create_batch", custom: true do
      header = %{
        "sender_batch_id" => "Payouts_2018_100007",
        "email_subject" => "You have a payout!",
        "email_message" => "You have received a payout! Thanks for using our service!"
      }
      payout_list = [
        %{
          "recipient_type" => "EMAIL",
          "amount" => %{
            "value" => "9.87",
            "currency" => "USD"
          },
          "note" => "Thanks for your patronage!",
          "sender_item_id" => "201403140001",
          "receiver" => "receiver@example.com",
          "alternate_notification_method" => %{
            "phone" => %{
              "country_code" => "91",
              "national_number" => "9999988888"
            }
          },
          "notification_language" => "fr-FR"
        },
        %{
          "recipient_type" => "PHONE",
          "amount" => %{
            "value" => "112.34",
            "currency" => "USD"
          },
          "note" => "Thanks for your support!",
          "sender_item_id" => "201403140002",
          "receiver" => "91-734-234-1234"
        },
        %{
          "recipient_type" => "PAYPAL_ID",
          "amount" => %{
            "value" => "5.32",
            "currency" => "USD"
          },
          "note" => "Thanks for your patronage!",
          "sender_item_id" => "201403140003",
          "receiver" => "G83JXTJ5EHCQ2"
        }
      ]

      assert {:ok,
                  %{
                    batch_header: %{batch_status: "PENDING", payout_batch_id: "5UXD2E8A7EBQJ", sender_batch_header: %{email_message: "You have received a payout! Thanks for using our service!", email_subject: "You have a payout!", sender_batch_id: "Payouts_2018_100008"}}
                  }
              } = PayPal.Payments.Payouts.create_batch(header, payout_list)
    end
  end

  test "when creating a payment batch returns an error tuple" do
    use_cassette "payouts_create_payout_error", custom: true do
      assert {:error, :malformed_request} = PayPal.Payments.Payouts.create_batch(%{}, [nil])
    end
  end

  test "get payouts batch" do
    use_cassette "payouts_get_payouts_batch", custom: true do
      assert { :ok, %{ batch_header: %{ payout_batch_id: "FYXMPQTX4JC9N", batch_status: "PROCESSING"} } } = PayPal.Payments.Payouts.get_payouts_batch("FYXMPQTX4JC9N")
    end
  end

  test "get payouts batch returns 404 tuple for non-existant batch" do
    use_cassette "payouts_get_payouts_batch_error", custom: true do
      assert {:ok, :not_found} = PayPal.Payments.Payouts.get_payouts_batch("DOESNTEXIST")
    end
  end

  test "get payout" do
    use_cassette "payouts_get_payout", custom: true do
      assert {:ok, %{ payout_item_id: "8AELMXH8UB2P8", transaction_id: "0C413693MN970190K" }} = PayPal.Payments.Payouts.get_payout("8AELMXH8UB2P8")
    end
  end

  test "get payout with invalid ID returns { :ok, :not_found }" do
    use_cassette "payouts_get_payout_error", custom: true do
      assert {:ok, :not_found} = PayPal.Payments.Payouts.get_payout("DOESNTEXIST")
    end
  end

  test "cancel payout" do
    use_cassette "payouts_cancel", custom: true do
      assert { :ok, %{ payout_item_id: "5KUDKLF8SDC7S", transaction_id: "1DG93452WK758815H", transaction_status: "RETURNED"}} = PayPal.Payments.Payouts.cancel("5KUDKLF8SDC7S")
    end
  end

  test "cancel payout already claimed error" do
    use_cassette "payouts_cancel_already_claimed", custom: true do
      assert {:error, :malformed_request } = PayPal.Payments.Payouts.cancel("YYKMVR2AVSVZ4")
    end
  end

  test "cancel payout 404 error" do
    use_cassette "payouts_cancel_notfound", custom: true do
      assert { :ok, :not_found } = PayPal.Payments.Payouts.cancel("DOESNTEXIST")
    end
  end
end
