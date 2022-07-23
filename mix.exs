defmodule Scrivener.Phoenix.MixProject do
  use Mix.Project

  defp elixirc_paths(:test), do: ~W[lib test/support]
  defp elixirc_paths(_), do: ~W[lib]

  def project do
    [
      app: :scrivener_phoenix,
      version: "0.3.2",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      source_url: "https://github.com/julp/scrivener_phoenix",
      elixirc_paths: elixirc_paths(Mix.env()),
      dialyzer: [plt_add_apps: [:mix, :ex_unit]],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    ~S"""
    Helper to render scrivener paginations in phoenix.

    Features:

      * reversed pagination (`3 2 1` instead of traditional `1 2 3`)
      * *page* parameter can be directly passed through URL's path (ie be part of your route, eg: /blog/page/3 instead of /blog/?page=3)
    """
  end

  defp package do
    [
      files: ~W[lib priv mix.exs CHANGELOG.md README.md],
      licenses: ["BSD"],
      links: %{"GitHub" => "https://github.com/julp/scrivener_phoenix"},
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gettext, "~> 0.20"},
      {:scrivener, "~> 2.5"},
      #{:phoenix_html, "~> 2.11"}, # pulled by phoenix_live_view
      {:phoenix_live_view, ">= 0.16.0"},
      {:ex_doc, "~> 0.25", only: :dev, runtime: false},
      # test
      {:jason, "~> 1.2", only: :test},
      #{:phoenix, "~> 1.6", only: :test}, # pulled by phoenix_live_view
      {:excoveralls, "~> 0.14", only: :test},
      {:dialyxir, "~> 1.0", only: ~W[dev test]a, runtime: false},
    ]
  end
end
