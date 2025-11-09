# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule SympyMcp.MixProject do
  use Mix.Project

  def project do
    [
      app: :sympy_mcp,
      version: "1.0.0-dev1",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      releases: releases(),
      deps: deps(),
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore.exs"
      ],
      test_coverage: [
        summary: [threshold: 70],
        ignore_modules: [
          SympyMcp.NativeService,
          Mix.Tasks.Mcp.Server,
          SympyMcp.HttpPlugWrapper,
          SympyMcp.HttpServer,
          SympyMcp.Router
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {SympyMcp.Application, []},
      applications: [:logger, :ex_mcp, :pythonx, :plug_cowboy]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_mcp, git: "https://github.com/fire/ex_mcp.git", branch: "master"},
      {:jason, "~> 1.4"},
      {:pythonx, "~> 0.4.0", runtime: false},
      {:dialyxir, "~> 1.4.6", only: [:dev], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  # Release configuration
  defp releases do
    [
      sympy_mcp: [
        include_executables_for: [:unix],
        applications: [sympy_mcp: :permanent]
      ]
    ]
  end
end
