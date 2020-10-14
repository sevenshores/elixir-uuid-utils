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
      docs: docs(),
      source_url: "https://github.com/sevenshores/elixir-uuid-utils",
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Application configuration.
  def application do
    [
      extra_applications: [:crypto]
    ]
  end

  # List of dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev},
      {:earmark, "~> 1.2", only: :dev},
      {:benchfella, "~> 0.3", only: :dev}
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
