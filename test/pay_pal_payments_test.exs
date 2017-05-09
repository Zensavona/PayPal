defmodule PayPalPaymentsTest do
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
end
