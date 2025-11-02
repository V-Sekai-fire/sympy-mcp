# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule SympyMcp.NativeService do
  @moduledoc """
  Native BEAM service for SymPy MCP using ex_mcp library.
  Provides symbolic mathematics tools via MCP protocol.
  """

  use ExMCP.Server,
    name: "SymPy MCP Server",
    version: "0.1.0"

  # Define SymPy tools using ex_mcp DSL
  deftool "sympy_solve" do
    meta do
      name("Solve Equation")
      description("Solves a symbolic equation for a variable using SymPy")
    end

    input_schema(%{
      type: "object",
      properties: %{
        equation: %{
          type: "string",
          description: "String representation of the equation (e.g., 'x**2 - 1')"
        },
        variable: %{
          type: "string",
          description: "String representation of the variable to solve for (e.g., 'x')"
        }
      },
      required: ["equation", "variable"]
    })
  end

  deftool "sympy_simplify" do
    meta do
      name("Simplify Expression")
      description("Simplifies a symbolic expression using SymPy")
    end

    input_schema(%{
      type: "object",
      properties: %{
        expression: %{
          type: "string",
          description: "String representation of the expression"
        }
      },
      required: ["expression"]
    })
  end

  deftool "sympy_differentiate" do
    meta do
      name("Differentiate Expression")
      description("Computes the derivative of an expression using SymPy")
    end

    input_schema(%{
      type: "object",
      properties: %{
        expression: %{
          type: "string",
          description: "String representation of the expression"
        },
        variable: %{
          type: "string",
          description: "String representation of the variable to differentiate with respect to"
        }
      },
      required: ["expression", "variable"]
    })
  end

  deftool "sympy_integrate" do
    meta do
      name("Integrate Expression")
      description("Computes the integral of an expression using SymPy")
    end

    input_schema(%{
      type: "object",
      properties: %{
        expression: %{
          type: "string",
          description: "String representation of the expression"
        },
        variable: %{
          type: "string",
          description: "String representation of the variable to integrate with respect to"
        }
      },
      required: ["expression", "variable"]
    })
  end

  deftool "sympy_expand" do
    meta do
      name("Expand Expression")
      description("Expands a symbolic expression using SymPy")
    end

    input_schema(%{
      type: "object",
      properties: %{
        expression: %{
          type: "string",
          description: "String representation of the expression"
        }
      },
      required: ["expression"]
    })
  end

  deftool "sympy_factor" do
    meta do
      name("Factor Expression")
      description("Factors a symbolic expression using SymPy")
    end

    input_schema(%{
      type: "object",
      properties: %{
        expression: %{
          type: "string",
          description: "String representation of the expression"
        }
      },
      required: ["expression"]
    })
  end

  deftool "sympy_evaluate" do
    meta do
      name("Evaluate Expression")
      description("Evaluates a symbolic expression numerically using SymPy")
    end

    input_schema(%{
      type: "object",
      properties: %{
        expression: %{
          type: "string",
          description: "String representation of the expression"
        },
        substitutions: %{
          type: "object",
          description: "Map of variable names to numeric values for substitution"
        }
      },
      required: ["expression"]
    })
  end

  # Tool call handlers
  @impl true
  def handle_tool_call("sympy_solve", %{"equation" => equation, "variable" => variable}, state) do
    case SympyMcp.SympyTools.solve(equation, variable) do
      {:ok, solutions} ->
        {:ok, %{content: [text("Solutions: #{inspect(solutions)}")]}, state}

      {:error, reason} ->
        {:error, "Failed to solve equation: #{reason}", state}
    end
  end

  @impl true
  def handle_tool_call("sympy_simplify", %{"expression" => expression}, state) do
    case SympyMcp.SympyTools.simplify(expression) do
      {:ok, simplified} ->
        {:ok, %{content: [text("Simplified: #{simplified}")]}, state}

      {:error, reason} ->
        {:error, "Failed to simplify expression: #{reason}", state}
    end
  end

  @impl true
  def handle_tool_call("sympy_differentiate", %{"expression" => expression, "variable" => variable}, state) do
    case SympyMcp.SympyTools.differentiate(expression, variable) do
      {:ok, derivative} ->
        {:ok, %{content: [text("Derivative: #{derivative}")]}, state}

      {:error, reason} ->
        {:error, "Failed to differentiate expression: #{reason}", state}
    end
  end

  @impl true
  def handle_tool_call("sympy_integrate", %{"expression" => expression, "variable" => variable}, state) do
    case SympyMcp.SympyTools.integrate(expression, variable) do
      {:ok, integral} ->
        {:ok, %{content: [text("Integral: #{integral}")]}, state}

      {:error, reason} ->
        {:error, "Failed to integrate expression: #{reason}", state}
    end
  end

  @impl true
  def handle_tool_call("sympy_expand", %{"expression" => expression}, state) do
    case SympyMcp.SympyTools.expand(expression) do
      {:ok, expanded} ->
        {:ok, %{content: [text("Expanded: #{expanded}")]}, state}

      {:error, reason} ->
        {:error, "Failed to expand expression: #{reason}", state}
    end
  end

  @impl true
  def handle_tool_call("sympy_factor", %{"expression" => expression}, state) do
    case SympyMcp.SympyTools.factor(expression) do
      {:ok, factored} ->
        {:ok, %{content: [text("Factored: #{factored}")]}, state}

      {:error, reason} ->
        {:error, "Failed to factor expression: #{reason}", state}
    end
  end

  @impl true
  def handle_tool_call("sympy_evaluate", %{"expression" => expression} = args, state) do
    substitutions = Map.get(args, "substitutions", %{})

    case SympyMcp.SympyTools.evaluate(expression, substitutions) do
      {:ok, result} ->
        {:ok, %{content: [text("Result: #{result}")]}, state}

      {:error, reason} ->
        {:error, "Failed to evaluate expression: #{reason}", state}
    end
  end

  # Fallback for unknown tools
  @impl true
  def handle_tool_call(tool_name, _args, state) do
    {:error, "Tool not found: #{tool_name}", state}
  end
end
