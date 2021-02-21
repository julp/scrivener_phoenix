defmodule Scrivener.Phoenix.MixProject do
  use Mix.Project

  def project do
    [
      app: :scrivener_phoenix,
      version: "0.1.0",
      elixir: "~> 1.7",
      compilers: ~W[gettext]a ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      source_url: "https://github.com/julp/scrivener_phoenix"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description() do
    ~S"""
    Helper to render scrivener paginations in phoenix.

    Features:

      * reversed pagination (`3 2 1` instead of traditional `1 2 3`)
      * *page* parameter can be directly passed through URL's path (ie be part of your route, eg: /blog/page/3 instead of /blog/?page=3)
    """
  end

  defp package() do
    [
      files: ["lib", "priv", "mix.exs", "README*"],
      licenses: ["BSD"],
      links: %{"GitHub" => "https://github.com/julp/scrivener_phoenix"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gettext, ">= 0.0.0"},
      {:scrivener, "~> 2.5"},
      {:phoenix_html, "~> 2.11"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end
end
