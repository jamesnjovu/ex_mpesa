defmodule ExMpesa.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/james-njovu/ex_mpesa"
  @description "An Elixir library for integrating with the Vodacom M-Pesa OpenAPI"

  def project do
    [
      app: :ex_mpesa,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: @description,
      package: package(),
      deps: deps(),
      docs: docs(),
      name: "ExMpesa",
      source_url: @source_url
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExMpesa.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.2"},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: "ex_mpesa",
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE),
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "LICENSE"],
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"],
      groups_for_modules: [
        "Core": [
          ExMpesa,
          ExMpesa.Application
        ],
        "Session Management": [
          ExMpesa.GenerateSessionKey
        ],
        "Transactions": [
          ExMpesa.Transactions
        ],
        "Internal": [
          ExMpesa.HttpRequest
        ]
      ]
    ]
  end
end
