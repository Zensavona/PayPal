defmodule PayPal.Config do
  @moduledoc """
  Documentation for PayPal.Config

  Basically this is just for getting configuration values

  ## Examples

    iex(1)> PayPal.Config.get
    %{client_id: "CLIENT_ID", client_secret: "CLIENT_SECRET"}
  """

  @doc """
  Get the configuration object, this reads both the config file and system environment variables.
  Env vars are first priority, config second.

  Environment vars:
  - PAYPAL_CLIENT_ID
  - PAYPAL_CLIENT_SECRET

  Example config.exs sample:

  config :pay_pal,
    client_id: "CLIENT_ID",
    client_secret: "CLIENT_SECRET"

  ## Examples

    iex(1)> PayPal.Config.get
    %{client_id: "CLIENT_ID", client_secret: "CLIENT_SECRET"}
  """
  def get do
    case !is_nil(System.get_env("PAYPAL_CLIENT_ID")) && !is_nil(System.get_env("PAYPAL_CLIENT_SECRET")) do
      true ->
        %{client_id: System.get_env("PAYPAL_CLIENT_ID"), client_secret: System.get_env("PAYPAL_CLIENT_SECRET")}
      _ ->
        %{client_id: Application.get_env(:pay_pal, :client_id), client_secret: Application.get_env(:pay_pal, :client_secret)}
    end
  end
end
