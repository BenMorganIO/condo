defmodule Condo.MixProject do
  use Mix.Project

  def project do
    [
      app: :condo,
      version: "0.1.3",
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
      {:dialyxir, "~> 1.0.0-rc.3", only: [:dev], runtime: false},
      {:ecto, "~> 2.2"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:postgrex, ">= 0.11.0", optional: true}
    ]
  end
end
