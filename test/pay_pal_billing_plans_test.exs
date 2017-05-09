defmodule PayPalBillingPlansTest do
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

  test "get billing plans" do
    use_cassette "billing_plans_get_plans" do
      resp = PayPal.Billing.Plans.list()
      assert resp == {:ok,
                       [%{create_time: "2017-05-02T08:04:20.411Z",
                            description: "Plan with regular and trial payment definitions.",
                            id: "P-3C560437P9994340RZAYE2OY",
                            links: [%{href: "https://api.sandbox.paypal.com/v1/payments/billing-plans/P-3C560437P9994340RZAYE2OY",
                               method: "GET", rel: "self"}],
                            name: "Plan with Regular and Trial Payment Definitions", state: "CREATED",
                            type: "FIXED", update_time: "2017-05-02T08:04:20.411Z"}]}
    end
  end

  test "get billing plans, fail with bad credentials" do
    use_cassette "billing_plans_get_plans_unauthorised" do
      resp = PayPal.Billing.Plans.list()
      assert resp == {:error, :unauthorised}
    end
  end

  test "get billing plans, fail timeout" do
    use_cassette "billing_plans_get_plans_timeout" do
      resp = PayPal.Billing.Plans.list()
      assert resp == {:error, :bad_network}
    end
  end

  test "create billing plan" do
    plan = %{
      name: "Test Plan",
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

    use_cassette "billing_plans_create_plan" do
      resp = PayPal.Billing.Plans.create(plan)
      assert resp == {:ok, %{description: "Plan with regular and trial payment definitions.", merchant_preferences: %{auto_bill_amount: "YES", cancel_url: "http://www.paypal.com/cancel", initial_fail_amount_action: "CONTINUE", max_fail_attempts: "0", return_url: "http://www.paypal.com", setup_fee: %{currency: "USD", value: "1"}}, name: "Test Plan", type: "FIXED", payment_definitions: [%{amount: %{currency: "USD", value: "100"}, cycles: "12", frequency_interval: "2", name: "Regular payment definition", type: "REGULAR", charge_models: [%{amount: %{currency: "USD", value: "10"}, type: "SHIPPING", id: "CHM-67G516347U321241T4ET465A"}, %{amount: %{currency: "USD", value: "12"}, type: "TAX", id: "CHM-60D809754G70990014ET465A"}], frequency: "Month", id: "PD-9A748277HB680373H4ET465A"}], create_time: "2017-05-07T04:25:34.324Z", id: "P-1YH704535C135734P4ET465A", links: [%{href: "https://api.sandbox.paypal.com/v1/payments/billing-plans/P-1YH704535C135734P4ET465A", method: "GET", rel: "self"}], state: "CREATED", update_time: "2017-05-07T04:25:34.324Z"}}
    end
  end

  test "create billing plan, fail timeout" do
    plan = %{
      name: "Test Plan",
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

    use_cassette "billing_plans_create_plan_error" do
      resp = PayPal.Billing.Plans.create(plan)
      assert resp == {:error, :bad_network}
    end
  end

  test "get billing plan by ID" do
    # Application.put_env(:pay_pal, :access_token, "A21AAFs89rwmm06vnCaUq30QCFhPYkzphr3r6H3R2ou9SCK0cX1-DURmUMz_FIqNXfQq-MzjCyOkOk41i1MUcluPntlKTM3GQ")
    use_cassette "billing_plans_get_plan" do
      resp = PayPal.Billing.Plans.show("P-3C560437P9994340RZAYE2OY")
      assert resp == {:ok, %{create_time: "2017-05-02T08:04:20.411Z", description: "Plan with regular and trial payment definitions.", id: "P-3C560437P9994340RZAYE2OY", links: [%{href: "https://api.sandbox.paypal.com/v1/payments/billing-plans/P-3C560437P9994340RZAYE2OY", method: "GET", rel: "self"}], name: "Plan with Regular and Trial Payment Definitions", state: "CREATED", type: "FIXED", update_time: "2017-05-02T08:04:20.411Z", merchant_preferences: %{auto_bill_amount: "YES", cancel_url: "http://www.paypal.com/cancel", initial_fail_amount_action: "CONTINUE", max_fail_attempts: "0", return_url: "http://www.paypal.com", setup_fee: %{currency: "USD", value: "1"}}, payment_definitions: [%{amount: %{currency: "USD", value: "100"}, charge_models: [%{amount: %{currency: "USD", value: "12"}, id: "CHM-8K016037XD486311FZAYE2OY", type: "TAX"}, %{amount: %{currency: "USD", value: "10"}, id: "CHM-0G830639S6488053MZAYE2OY", type: "SHIPPING"}], cycles: "12", frequency: "Month", frequency_interval: "2", id: "PD-88G018863E918211XZAYE2OY", name: "Regular payment definition", type: "REGULAR"}]}}
    end
  end

  test "get billing plan by ID, not found" do
    use_cassette "billing_plans_get_plan_not_found" do
      resp = PayPal.Billing.Plans.show("P-3C560437P9994340RZAYE21X")
      assert resp == {:ok, nil}
    end
  end

  test "get billing plan by ID, fail with bad credentials" do
    use_cassette "billing_plans_get_plan_unauthorised" do
      resp = PayPal.Billing.Plans.show("P-3C560437P9994340RZAYE2OY")
      assert resp == {:error, :unauthorised}
    end
  end

  test "update a billing plan" do
    op = [%{op: "replace", path: "/merchant-preferences", value: %{ cancel_url: "http://www.cancel.com" }}]
    use_cassette "billing_plans_update_plan" do
      resp = PayPal.Billing.Plans.update("P-3C560437P9994340RZAYE2OY", op)
      assert resp == {:ok, nil}
    end
  end

  test "update a billing plan, error with malformed request" do
    op = %{op: "replace", path: "/merchant-preferences", value: %{ cancel_url: "http://www.cancel.com" }}
    use_cassette "billing_plans_update_plan_error" do
      resp = PayPal.Billing.Plans.update("P-3C560437P9994340RZAYE2OY", op)
      assert resp == {:error, :malformed_request}
    end
  end
end
