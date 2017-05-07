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

    # System.put_env("PAYPAL_CLIENT_ID", "CLIENT_ID")
    # System.put_env("PAYPAL_CLIENT_SECRET", "CLIENT_SECRET")
    :ok
  end

  test "get billing plans" do
    # Application.put_env(:pay_pal, :access_token, "A21AAFs89rwmm06vnCaUq30QCFhPYkzphr3r6H3R2ou9SCK0cX1-DURmUMz_FIqNXfQq-MzjCyOkOk41i1MUcluPntlKTM3GQ")
    use_cassette "billing_plans_get_plans" do
      resp = PayPal.Billing.Plans.list()
      assert resp == {:ok,
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
end
