defmodule PayPalBillingAgreementsTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes", "fixture/custom_cassettes")
    ExVCR.Config.filter_url_params(true)
    ExVCR.Config.response_headers_blacklist(["paypal-debug-id", "Paypal-Debug-Id", "Set-Cookie"])
    ExVCR.Config.filter_request_headers("Authorization")
    ExVCR.Config.filter_sensitive_data("basic_auth\":\".+?\"", "basic_auth\":\"<REMOVED>\"")
    ExVCR.Config.filter_sensitive_data("app_id\":\".+?\"", "app_id\":\"<REMOVED>\"")
    ExVCR.Config.filter_sensitive_data("access_token\":\".+?\"", "access_token\":\"<REMOVED>\"")
    :ok
  end

  test "create a billing agreement" do
    use_cassette "billing_agreements_create_agreement" do
      agreement = %{
        name: "Magazine Subscription",
        description: "Monthly subscription with a regular monthly payment definition and two-month trial payment definition.",
        start_date: "2017-12-22T09:13:49Z",
        plan: %{
          id: "P-3C560437P9994340RZAYE2OY"
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
      resp = PayPal.Billing.Agreements.create(agreement)
      assert resp == {:ok, %{description: "Monthly subscription with a regular monthly payment definition and two-month trial payment definition.", links: [%{href: "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=EC-4U6216316A218783E", method: "REDIRECT", rel: "approval_url"}, %{href: "https://api.sandbox.paypal.com/v1/payments/billing-agreements/EC-4U6216316A218783E/agreement-execute", method: "POST", rel: "execute"}], name: "Magazine Subscription", plan: %{description: "Plan with regular and trial payment definitions.", id: "P-3C560437P9994340RZAYE2OY", merchant_preferences: %{auto_bill_amount: "YES", cancel_url: "http://www.cancel.com", initial_fail_amount_action: "CONTINUE", max_fail_attempts: "0", return_url: "http://www.paypal.com", setup_fee: %{currency: "USD", value: "1"}}, name: "Plan with Regular and Trial Payment Definitions", payment_definitions: [%{amount: %{currency: "USD", value: "100"}, charge_models: [%{amount: %{currency: "USD", value: "12"}, id: "CHM-8K016037XD486311FZAYE2OY", type: "TAX"}, %{amount: %{currency: "USD", value: "10"}, id: "CHM-0G830639S6488053MZAYE2OY", type: "SHIPPING"}], cycles: "12", frequency: "Month", frequency_interval: "2", id: "PD-88G018863E918211XZAYE2OY", name: "Regular payment definition", type: "REGULAR"}], state: "ACTIVE", type: "FIXED"}, start_date: "2017-12-22T09:13:49Z"}}
    end
  end

  test "create a billing agreement, fail with error" do
    use_cassette "billing_agreements_create_agreement_error" do
      agreement = %{
        name: "Magazine Subscription",
        description: "Monthly subscription with a regular monthly payment definition and two-month trial payment definition.",
        plan: %{
          id: "P-3C560437P9994340RZAYEXXX"
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
      resp = PayPal.Billing.Agreements.create(agreement)
      assert resp == {:error, :malformed_request}
    end
  end

  test "execute a billing agreement" do
    use_cassette "billing_agreements_execute_agreement" do
      resp = PayPal.Billing.Agreements.execute("EC-6PS7165677242505H")
      assert resp == {:ok, %{agreement_details: %{cycles_completed: "0", cycles_remaining: "12", failed_payment_count: "0", final_payment_date: "2019-10-22T10:00:00Z", last_payment_amount: %{value: "1.00"}, last_payment_date: "2017-05-07T07:53:31Z", next_billing_date: "2017-12-22T10:00:00Z", outstanding_balance: %{value: "0.00"}}, description: "Monthly subscription with a regular monthly payment definition and two-month trial payment definition.", id: "I-YLRFBEKMH34T", links: [%{href: "https://api.sandbox.paypal.com/v1/payments/billing-agreements/I-YLRFBEKMH34T", method: "GET", rel: "self"}], payer: %{payer_info: %{email: "tedelex06@gmail.com", first_name: "Zen", last_name: "Savona", payer_id: "TM63YY9GU9Q8C", shipping_address: %{city: "Quimby", country_code: "US", line1: "751235 Stout Drive", line2: "0976249 Elizabeth Court", postal_code: "51049", recipient_name: "Zen Savona", state: "IA"}}, payment_method: "paypal", status: "unverified"}, plan: %{currency_code: "USD", links: [], merchant_preferences: %{auto_bill_amount: "YES", max_fail_attempts: "0", setup_fee: %{value: "1.00"}}, payment_definitions: [%{amount: %{value: "100.00"}, charge_models: [%{amount: %{value: "12.00"}, type: "TAX"}, %{amount: %{value: "10.00"}, type: "SHIPPING"}], cycles: "12", frequency: "Month", frequency_interval: "2", type: "REGULAR"}]}, shipping_address: %{city: "Quimby", country_code: "US", line1: "751235 Stout Drive", line2: "0976249 Elizabeth Court", postal_code: "51049", recipient_name: "Zen Savona", state: "IA"}, start_date: "2017-12-22T08:00:00Z", state: "Active"}}
    end
  end

  test "update a billing agreement" do
    op = [
      %{
        op: "replace",
        path: "/",
        value: %{
          start_date: "2017-12-22T09:13:49Z",
        }
      }
    ]
    use_cassette "billing_agreements_update_agreement" do
      resp = PayPal.Billing.Agreements.update("I-YLRFBEKMH34T", op)
      assert resp == {:ok, nil}
    end
  end

  test "update a billing agreement, error with malformed request" do
    op = %{
      op: "replace",
      path: "/",
      value: %{
        description: "Updated description.",
        start_date: "2017-12-22T09:13:49Z",
        shipping_address: %{
          line1: "Hotel Blue Diamond",
          line2: "Church Street",
          city: "San Jose",
          state: "CA",
          postal_code: "95112",
          country_code: "US"
        }
      }
    }
    use_cassette "billing_agreements_update_agreement_error" do
      resp = PayPal.Billing.Agreements.update("I-YLRFBEKMH34T", op)
      assert resp == {:error, :malformed_request}
    end
  end

  test "get a billing agreement by ID" do
    use_cassette "billing_agreement_show" do
      resp = PayPal.Billing.Agreements.show("I-YLRFBEKMH34T")
      assert resp == {:ok, %{agreement_details: %{cycles_completed: "0", cycles_remaining: "12", failed_payment_count: "0", final_payment_date: "2019-10-22T10:00:00Z", last_payment_amount: %{currency: "USD", value: "1.00"}, last_payment_date: "2017-05-07T07:53:31Z", next_billing_date: "2017-12-22T10:00:00Z", outstanding_balance: %{currency: "USD", value: "0.00"}}, description: "Monthly subscription with a regular monthly payment definition and two-month trial payment definition.", id: "I-YLRFBEKMH34T", links: [%{href: "https://api.sandbox.paypal.com/v1/payments/billing-agreements/I-YLRFBEKMH34T/suspend", method: "POST", rel: "suspend"}, %{href: "https://api.sandbox.paypal.com/v1/payments/billing-agreements/I-YLRFBEKMH34T/re-activate", method: "POST", rel: "re_activate"}, %{href: "https://api.sandbox.paypal.com/v1/payments/billing-agreements/I-YLRFBEKMH34T/cancel", method: "POST", rel: "cancel"}, %{href: "https://api.sandbox.paypal.com/v1/payments/billing-agreements/I-YLRFBEKMH34T/bill-balance", method: "POST", rel: "self"}, %{href: "https://api.sandbox.paypal.com/v1/payments/billing-agreements/I-YLRFBEKMH34T/set-balance", method: "POST", rel: "self"}], payer: %{payer_info: %{email: "tedelex06@gmail.com", first_name: "Zen", last_name: "Savona", payer_id: "TM63YY9GU9Q8C", shipping_address: %{city: "Quimby", country_code: "US", line1: "751235 Stout Drive", line2: "0976249 Elizabeth Court", postal_code: "51049", recipient_name: "Zen Savona", state: "IA"}}, payment_method: "paypal", status: "unverified"}, plan: %{merchant_preferences: %{auto_bill_amount: "YES", max_fail_attempts: "0", setup_fee: %{currency: "USD", value: "1.00"}}, payment_definitions: [%{amount: %{currency: "USD", value: "100.00"}, charge_models: [%{amount: %{currency: "USD", value: "12.00"}, type: "TAX"}, %{amount: %{currency: "USD", value: "10.00"}, type: "SHIPPING"}], cycles: "12", frequency: "Month", frequency_interval: "2", type: "REGULAR"}]}, shipping_address: %{city: "Quimby", country_code: "US", line1: "751235 Stout Drive", line2: "0976249 Elizabeth Court", postal_code: "51049", recipient_name: "Zen Savona", state: "IA"}, start_date: "2017-12-22T08:00:00Z", state: "Active"}}
    end
  end

#   test "set balance for agreement" do
#     use_cassette "billing_agreement_set_balance" do
#       resp = PayPal.Billing.Agreements.set_balance("I-YLRFBEKMH34T", %{value: "10", currency: "USD"})
#       assert resp == {:ok, nil}
#     end
#   end

  test "bill agreement for balance, fail because not enough balance" do
    use_cassette "billing_agreement_bill_balance_error" do
      resp = PayPal.Billing.Agreements.bill_balance("I-YLRFBEKMH34T", %{note: "something", amount: %{ value: "10", currency: "USD"}})
      assert resp == {:error, :malformed_request}
    end
  end

  test "cancel billing agreement" do
    use_cassette "billing_agreement_cancel" do
      resp = PayPal.Billing.Agreements.cancel("I-YLRFBEKMH34T", "test note")
      assert resp == {:ok, nil}
    end
  end

  test "list agreement transactions" do
    use_cassette "billing_agrrment_transactions" do
      resp = PayPal.Billing.Agreements.transactions "I-5TCE8UV35GT7", "2017-01-01", "2017-06-01"
      assert resp == {:ok,
                         [%{payer_email: "", payer_name: "Zen Savona", status: "Created",
                            time_stamp: "2017-05-09T00:22:54Z", time_zone: "GMT",
                            transaction_id: "I-5TCE8UV35GT7", transaction_type: "Recurring Payment"},
                          %{amount: %{currency: "USD", value: "1.00"},
                            fee_amount: %{currency: "USD", value: "-0.33"},
                            net_amount: %{currency: "USD", value: "0.67"},
                            payer_email: "tedelex06@gmail.com", payer_name: "Zen Savona",
                            status: "Completed", time_stamp: "2017-05-09T00:22:58Z", time_zone: "GMT",
                            transaction_id: "12D08841828909040",
                            transaction_type: "Recurring Payment"}]}
    end
  end

  test "suspend an agreement" do
    use_cassette "billing_agreement_suspend" do
      resp = PayPal.Billing.Agreements.suspend "I-5TCE8UV35GT7", "some reason"
      assert resp == {:ok, nil}
    end
  end

  test "reactivate an agreement" do
    use_cassette "billing_agreement_reactivate" do
      resp = PayPal.Billing.Agreements.reactivate "I-5TCE8UV35GT7", "some other reason"
      assert resp == {:ok, nil}
    end
  end
end
