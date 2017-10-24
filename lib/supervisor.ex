defmodule PayPal.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  require Logger
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    #children = if Mix.env == :test, do: [], else: [worker(Task, [&refresh_token/0], [restart: :permanent])]
    children = [worker(Task, [&refresh_token/0], [restart: :permanent])]

    opts = [strategy: :one_for_one, name: PayPal.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp refresh_token(seconds \\ 1000) do
    case PayPal.API.get_oauth_token() do
      {:ok, {token, seconds}} ->
        Application.put_env(:pay_pal, :access_token, token)
        Logger.info "[PayPal] Refreshed access token, expires in #{seconds} seconds"
        :timer.sleep(seconds * 1000)
        refresh_token(seconds)
      {:error, reason} ->
        Logger.error "[PayPal] Refreshing access token failed with reason: #{reason}, retrying in 1 second"
        :timer.sleep(1000)
        refresh_token()
    end
  end
end
