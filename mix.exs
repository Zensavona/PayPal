defmodule PayPal.Mixfile do
  use Mix.Project

  def project do
    [
      app: :pay_pal,
      version: "0.0.6",
      elixir: "~> 1.15",
      build_embedded: Application.get_env(:pay_pal, :environment) == :prod,
      start_permanent: Application.get_env(:pay_pal, :environment) == :prod,
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      deps: deps(),
      docs: [extras: ["README.md"], main: "readme"],
      dialyzer: [plt_add_deps: :true]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :httpoison],
      mod: {PayPal.Application, []}
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 2.2"},
      {:poison, "~> 6.0"},
      {:oauth2, "~> 2.1"},
      {:exvcr, "~> 0.17", only: [:dev, :test]},
      {:ex_doc, "~> 0.37", only: [:dev, :docs]},
      {:excoveralls, "~> 0.18", only: [:dev, :test]},
      {:inch_ex, "~> 2.0", only: [:dev, :docs]},
      {:credo, "~> 1.7", only: :dev},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    """
    Elixir library for working with the PayPal REST API.
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      keywords: ["Elixir", "PayPal", "REST", "Payments", "API"],
      maintainers: ["Zen Savona"],
      links: %{"GitHub" => "https://github.com/zensavona/paypal",
               "Docs" => "https://hexdocs.pm/paypal"}
    ]
  end
end
