defmodule UUID.Mixfile do
  use Mix.Project

  @app :uuid_utils
  @version "1.3.0"

  def project do
    [
      app: @app,
      name: "UUID",
      version: @version,
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      docs: docs(),
      source_url: "https://github.com/sevenshores/elixir-uuid-utils",
      description: description(),
      package: package(),
      deps: deps(),
      xref: [exclude: [:cover, EEx]],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: preferred_cli_env()
    ]
  end

  # Application configuration.
  def application do
    [
      extra_applications: [:crypto]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp preferred_cli_env do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test
    ]
  end

  # List of dependencies.
  defp deps do
    [
      {:benchfella, "~> 0.3", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  # Description.
  defp description do
    """
    UUID generator and utilities for Elixir.
    """
  end

  # Package info.
  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Ryan Winchester"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/sevenshores/elixir-uuid-utils"}
    ]
  end

  defp docs do
    [
      extras: ["README.md", "CHANGELOG.md"],
      main: "readme",
      source_ref: "v#{@version}"
    ]
  end
end
