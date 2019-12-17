defmodule Condo.MixProject do
  use Mix.Project

  def project do
    [
      app: :condo,
      version: "0.2.2",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Multi-tenant functions for Ecto. SaaS for Elixir.",
      package: [
        maintainers: ["Ben Morgan <ben@benmorgan.io>"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/BenMorganIO/condo"}
      ],
      source_url: "https://github.com/BenMorganIO/condo",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application, do: [extra_applications: [:logger]]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:ecto, "~> 3.0"},
      {:ecto_sql, "~> 3.0"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:excoveralls, "~> 0.10", only: :test},
      {:junit_formatter, ">= 0.0.0", only: :test},
      {:postgrex, ">= 0.11.0", optional: true}
    ]
  end
end
