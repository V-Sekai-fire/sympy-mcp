# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule MCPAriaSympy.CLI do
  @moduledoc """
  CLI module for the MCP Aria SymPy server.
  """

  def main(_args) do
    {:ok, _} = Application.ensure_all_started(:mcp_aria_sympy)
    Process.sleep(:infinity)
  end
end
