# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule SympyMcp.CLI do
  @moduledoc """
  CLI module for the MCP Aria SymPy server.
  """

  def main(_args) do
    {:ok, _} = Application.ensure_all_started(:sympy_mcp)
    Process.sleep(:infinity)
  end
end
