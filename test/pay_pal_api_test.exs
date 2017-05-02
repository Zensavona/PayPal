defmodule PayPalAPITest do
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

    System.put_env("PAYPAL_CLIENT_ID", "CLIENT_ID")
    System.put_env("PAYPAL_CLIENT_SECRET", "CLIENT_SECRET")

    :ok
  end

  test "get access token, fail with bad credentials" do
    use_cassette "api_access_token_unauthorised" do
      resp = PayPal.API.get_oauth_token()
      assert resp == {:error, :unauthorised}
    end
  end

  test "get access token, fail with timeout" do
    use_cassette "api_access_token_timeout" do
      resp = PayPal.API.get_oauth_token()
      assert resp == {:error, :bad_network}
    end
  end

  test "get access token" do
    use_cassette "api_access_token" do
      {resp, {_token, _secs}} = PayPal.API.get_oauth_token()
      assert resp == :ok
    end
  end
end
