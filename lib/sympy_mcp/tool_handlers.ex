# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule SympyMcp.ToolHandlers do
  @moduledoc """
  Tool execution handlers for MCP Aria SymPy server.
  Routes tool calls to the appropriate SymPy tool handlers.
  """

  # SymPy Tools - delegated to SympyToolHandlers
  def handle_tool_call("sympy_solve", args, state) do
    SympyMcp.SympyToolHandlers.handle_solve(args, state)
  end

  def handle_tool_call("sympy_simplify", args, state) do
    SympyMcp.SympyToolHandlers.handle_simplify(args, state)
  end

  def handle_tool_call("sympy_differentiate", args, state) do
    SympyMcp.SympyToolHandlers.handle_differentiate(args, state)
  end

  def handle_tool_call("sympy_integrate", args, state) do
    SympyMcp.SympyToolHandlers.handle_integrate(args, state)
  end

  def handle_tool_call("sympy_expand", args, state) do
    SympyMcp.SympyToolHandlers.handle_expand(args, state)
  end

  def handle_tool_call("sympy_factor", args, state) do
    SympyMcp.SympyToolHandlers.handle_factor(args, state)
  end

  def handle_tool_call("sympy_evaluate", args, state) do
    SympyMcp.SympyToolHandlers.handle_evaluate(args, state)
  end

  # Catch-all for unknown tools
  def handle_tool_call(tool_name, _args, state) do
    {:error, "Tool not found: #{tool_name}", state}
  end
end
