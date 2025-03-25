# PayPal

### Elixir library for working with the PayPal REST API.

[![Build Status](https://travis-ci.org/Zensavona/PayPal.svg?branch=master)](https://travis-ci.org/Zensavona/PayPal) [![Inline docs](http://inch-ci.org/github/zensavona/PayPal.svg)](http://inch-ci.org/github/zensavona/PayPal) [![Hex Docs](https://img.shields.io/badge/hex-docs-9768d1.svg)](https://hexdocs.pm/pay_pal) [![Coverage Status](https://coveralls.io/repos/github/Zensavona/PayPal/badge.svg?branch=master)](https://coveralls.io/github/Zensavona/PayPal?branch=master) [![Deps Status](https://beta.hexfaktor.org/badge/all/github/Zensavona/PayPal.svg)](https://beta.hexfaktor.org/github/Zensavona/PayPal) [![hex.pm version](https://img.shields.io/hexpm/v/pay_pal.svg)](https://hex.pm/packages/pay_pal) [![hex.pm downloads](https://img.shields.io/hexpm/dt/pay_pal.svg)](https://hex.pm/packages/pay_pal) [![License](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)

This is in development, currently the following parts of the API are working:

- access token rotation on expiry
- Billing Plans
- Billing Agreements
- Payments
- Payouts

These work fine and I am using them in production, they have test coverage. Check out the docs :)

# Installation

Add `:pay_pal` as a dependency to your project's `mix.exs`:

```elixir
defp deps do
  [
    {:pay_pal, "~> x.x.x"}
  ]
end
```

Configure your settings in your configuration files:

```elixir
config :pay_pal,
  client_id: "your_paypal_client_id",
  client_secret: "your_paypal_secret",
  environment: :sandbox
```