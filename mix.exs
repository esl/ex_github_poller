defmodule ExGithubPoller.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_github_poller,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  defp package() do
    [
      # These are the default files included in the package
      description: "simple library to pull repository events from github",
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*
         ),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/elixir-ecto/postgrex"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ExGithubPoller.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:confex, "~> 3.4.0"},
      {:tentacat, "~> 2.0.1"},
      {:exvcr, "~> 0.10", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
