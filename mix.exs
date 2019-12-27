defmodule Condo.MixProject do
  use Mix.Project

  def project do
    [
      app: :condo,
      version: "0.2.3",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
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

  if Mix.env() == :dev || Mix.env() == :test do
    def application do
      [mod: {Condo.TestApplication, []}, extra_applications: [:logger]]
    end
  else
    def application, do: [extra_applications: [:logger]]
  end

  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:ecto, "~> 3.3"},
      {:ecto_sql, "~> 3.3"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:excoveralls, "~> 0.10", only: :test},
      {:junit_formatter, ">= 0.0.0", only: :test},
      {:postgrex, ">= 0.11.0"}
    ]
  end

  defp aliases do
    [test: ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
