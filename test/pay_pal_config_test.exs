defmodule PayPalConfigTest do
  use ExUnit.Case
  doctest PayPal.Config

  test "get config from config.exs" do
    assert PayPal.Config.get() == %{client_id: "CLIENT_ID", client_secret: "CLIENT_SECRET"}
  end

  test "Get config from env vars" do
    System.put_env("PAYPAL_CLIENT_ID", "CLIENT_ID")
    System.put_env("PAYPAL_CLIENT_SECRET", "CLIENT_SECRET")
    assert PayPal.Config.get() == %{client_id: "CLIENT_ID", client_secret: "CLIENT_SECRET"}
  end

end
