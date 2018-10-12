defmodule Condo.MixProject do
  use Mix.Project

  def project do
    [
      app: :condo,
      version: "0.1.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Multi-tenant functions for Ecto. SaaS for Elixir.",
      package: [
        maintainers: ["Ben Morgan <ben@benmorgan.io>"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/BenMorganIO/condo"}
      ],
      source_url: "https://github.com/BenMorganIO/condo"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 2.2"},
      {:postgrex, ">= 0.11.0", optional: true},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
