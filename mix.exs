# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule MCP.AriaSympy.MixProject do
  use Mix.Project

  def project do
    [
      app: :mcp_aria_sympy,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      escript: [main_module: MCPAriaSympy.CLI],
      releases: releases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {MCP.AriaSympy.Application, []},
      applications: [:logger, :ex_mcp, :pythonx]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_mcp, git: "https://github.com/azmaveth/ex_mcp.git"},
      {:jason, "~> 1.4"},
      {:pythonx, "~> 0.4.0", runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  # Release configuration
  defp releases do
    [
      mcp_aria_sympy: [
        include_executables_for: [:unix],
        applications: [mcp_aria_sympy: :permanent]
      ]
    ]
  end
end
