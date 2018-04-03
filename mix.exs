defmodule ExHttpBench.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_http_bench,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:lhttpc, "~> 1.5"},
      {:hackney, "~> 1.11"},
      {:ibrowse, "~> 4.4"},
      {:cowboy, "~> 2.2"}
    ]
  end
end
