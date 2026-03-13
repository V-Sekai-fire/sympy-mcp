# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule SympyMcp.MCPHandler do
  @moduledoc """
  ExMCP Handler that exposes SymPy tools with camelCase inputSchema (like vsekai).
  Delegates tool execution to SympyMcp.NativeService.
  """
  use ExMCP.Server.Handler

  def get_capabilities do
    %{
      "tools" => %{"listChanged" => false},
      "resources" => %{"listChanged" => false},
      "prompts" => %{"listChanged" => false}
    }
  end

  @impl true
  def handle_initialize(_params, state) do
    {:ok,
     %{
       protocolVersion: "2025-06-18",
       serverInfo: %{name: "SymPy MCP Server", version: "1.0.0-dev1"},
       capabilities: %{tools: %{listChanged: false}, resources: %{listChanged: false}, prompts: %{listChanged: false}}
     }, state}
  end

  @impl true
  def handle_list_tools(_cursor, state) do
    tools =
      SympyMcp.NativeService.get_tools()
      |> Map.values()
      |> Enum.map(fn t -> %{name: t.name, description: t.description, inputSchema: t.input_schema} end)

    {:ok, tools, nil, state}
  end

  @impl true
  def handle_list_prompts(_cursor, state) do
    prompts = [
      %{
        name: "symbolic_math_helper",
        description:
          "Helps users perform symbolic mathematics operations with SymPy (solve, simplify, differentiate, integrate, expand, factor, evaluate)."
      }
    ]

    {:ok, prompts, nil, state}
  end

  @impl true
  def handle_get_prompt("symbolic_math_helper", args, state) do
    operation = Map.get(args, "operation", "simplify")
    expression = Map.get(args, "expression", "")
    variable = Map.get(args, "variable")
    guidance = build_operation_guidance(operation, expression, variable)

    messages = [
      %{
        role: "user",
        content: %{
          type: "text",
          text:
            "I want to #{operation} the expression: #{expression}#{if variable, do: " with variable #{variable}", else: ""}"
        }
      },
      %{role: "assistant", content: %{type: "text", text: guidance}}
    ]

    {:ok, %{messages: messages}, state}
  end

  def handle_get_prompt(_name, _arguments, state) do
    {:error, "Prompt not found", state}
  end

  @impl true
  def handle_list_resources(_cursor, state) do
    resources = [
      %{
        uri: "sympy://examples",
        name: "SymPy Example Expressions",
        description: "Common example expressions for testing SymPy operations"
      }
    ]

    {:ok, resources, nil, state}
  end

  @impl true
  def handle_read_resource("sympy://examples", state) do
    text = """
    SymPy Example Expressions

    Basic: x**2 + 2*x + 1, sin(x) + cos(x), exp(x) * log(x)
    Equations: x**2 - 4 = 0, x**2 + y**2 = 1
    Derivatives: x**2, sin(x), exp(x) * log(x)
    Integrals: x**2, 1/x, exp(-x**2)

    Use these with sympy_solve, sympy_simplify, sympy_differentiate, sympy_integrate, etc.
    """

    content = [%{uri: "sympy://examples", text: String.trim(text), mimeType: "text/plain"}]
    {:ok, content, state}
  end

  def handle_read_resource(_uri, state) do
    {:error, "Resource not found", state}
  end

  defp build_operation_guidance(operation, expression, variable) do
    base = "Use the sympy_#{operation} tool with the appropriate parameters."

    guidance_primary(operation, expression, variable) ||
      guidance_secondary(operation, expression, variable) ||
      "Available operations: solve, simplify, differentiate, integrate, expand, factor, evaluate. " <> base
  end

  defp guidance_primary("solve", expr, var),
    do: "To solve the equation #{expr} for #{var || "a variable"}, use sympy_solve with equation and variable."

  defp guidance_primary("simplify", expr, _var),
    do: "To simplify #{expr}, use sympy_simplify with expression."

  defp guidance_primary("differentiate", expr, var),
    do: "To differentiate #{expr} w.r.t. #{var || "x"}, use sympy_differentiate with expression and variable."

  defp guidance_primary("integrate", expr, var),
    do: "To integrate #{expr} w.r.t. #{var || "x"}, use sympy_integrate with expression and variable."

  defp guidance_primary(_, _, _), do: nil

  defp guidance_secondary("expand", expr, _var),
    do: "To expand #{expr}, use sympy_expand with expression."

  defp guidance_secondary("factor", expr, _var),
    do: "To factor #{expr}, use sympy_factor with expression."

  defp guidance_secondary("evaluate", expr, _var),
    do: "To evaluate #{expr} numerically, use sympy_evaluate with expression and optional substitutions."

  defp guidance_secondary(_, _, _), do: nil

  @impl true
  def handle_call_tool(name, arguments, state) do
    case GenServer.call(SympyMcp.NativeService, {:execute_tool, name, arguments}, 10_000) do
      {:ok, result} ->
        {:ok, result, state}

      {:error, reason} ->
        {:error, reason, state}
    end
  end
end
