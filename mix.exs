defmodule Fountainedge.MixProject do
  use Mix.Project

  def project do
    [
      app: :fountainedge,
      name: "Fountainedge",
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      source_url: "https://github.com/emden-norfolk/fountainedge"
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp description() do
    "Workflow engine with conditions, forks and parallel processes."
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "fountainedge",
      # These are the default files included in the package
      files: ~w(lib mix.exs README.md),
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/emden-norfolk/fountainedge"}
    ]
  end
end
