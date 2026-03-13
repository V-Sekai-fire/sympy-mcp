# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule SympyMcp.NativeService do
  @moduledoc """
  SymPy MCP tool execution and tool list (no deftool DSL).
  Runs as a named GenServer; MCPHandler calls get_tools/0 and GenServer.call(..., :execute_tool) over HTTP streaming.
  """

  use GenServer

  @spec child_spec(term()) :: Supervisor.child_spec()
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 5000
    }
  end

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name)
    genserver_opts = if name, do: [name: name], else: []
    GenServer.start_link(__MODULE__, opts, genserver_opts)
  end

  @doc false
  def get_tools do
    %{
      "sympy_solve" => %{
        name: "sympy_solve",
        description: "Solves a symbolic equation for a variable using SymPy",
        input_schema: %{
          "type" => "object",
          "properties" => %{
            "equation" => %{
              "type" => "string",
              "description" => "String representation of the equation (e.g., 'x**2 - 1')"
            },
            "variable" => %{
              "type" => "string",
              "description" => "String representation of the variable to solve for (e.g., 'x')"
            }
          },
          "required" => ["equation", "variable"]
        }
      },
      "sympy_simplify" => %{
        name: "sympy_simplify",
        description: "Simplifies a symbolic expression using SymPy",
        input_schema: %{
          "type" => "object",
          "properties" => %{
            "expression" => %{
              "type" => "string",
              "description" => "String representation of the expression"
            }
          },
          "required" => ["expression"]
        }
      },
      "sympy_differentiate" => %{
        name: "sympy_differentiate",
        description: "Computes the derivative of an expression using SymPy",
        input_schema: %{
          "type" => "object",
          "properties" => %{
            "expression" => %{"type" => "string", "description" => "String representation of the expression"},
            "variable" => %{
              "type" => "string",
              "description" => "String representation of the variable to differentiate with respect to"
            }
          },
          "required" => ["expression", "variable"]
        }
      },
      "sympy_integrate" => %{
        name: "sympy_integrate",
        description: "Computes the integral of an expression using SymPy",
        input_schema: %{
          "type" => "object",
          "properties" => %{
            "expression" => %{"type" => "string", "description" => "String representation of the expression"},
            "variable" => %{
              "type" => "string",
              "description" => "String representation of the variable to integrate with respect to"
            }
          },
          "required" => ["expression", "variable"]
        }
      },
      "sympy_expand" => %{
        name: "sympy_expand",
        description: "Expands a symbolic expression using SymPy",
        input_schema: %{
          "type" => "object",
          "properties" => %{
            "expression" => %{"type" => "string", "description" => "String representation of the expression"}
          },
          "required" => ["expression"]
        }
      },
      "sympy_factor" => %{
        name: "sympy_factor",
        description: "Factors a symbolic expression using SymPy",
        input_schema: %{
          "type" => "object",
          "properties" => %{
            "expression" => %{"type" => "string", "description" => "String representation of the expression"}
          },
          "required" => ["expression"]
        }
      },
      "sympy_evaluate" => %{
        name: "sympy_evaluate",
        description: "Evaluates a symbolic expression numerically using SymPy",
        input_schema: %{
          "type" => "object",
          "properties" => %{
            "expression" => %{"type" => "string", "description" => "String representation of the expression"},
            "substitutions" => %{
              "type" => "object",
              "description" => "Map of variable names to numeric values for substitution"
            }
          },
          "required" => ["expression"]
        }
      },
      "sympy_list_operations" => %{
        name: "sympy_list_operations",
        description:
          "Returns the list of available SymPy tool names (solve, simplify, differentiate, integrate, expand, factor, evaluate). Use this to discover what operations this server supports.",
        input_schema: %{"type" => "object", "properties" => %{}, "required" => []}
      }
    }
  end

  @impl true
  def init(_opts) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:execute_tool, tool_name, arguments}, _from, state) do
    case handle_tool_call(tool_name, arguments, state) do
      {:ok, result, new_state} -> {:reply, {:ok, result}, new_state}
      {:error, reason, new_state} -> {:reply, {:error, reason}, new_state}
    end
  end

  def handle_tool_call(tool_name, args, state) do
    case tool_name do
      "sympy_solve" ->
        handle_sympy_operation(
          &SympyMcp.SympyTools.solve/2,
          [args["equation"], args["variable"]],
          "solve equation",
          state
        )

      "sympy_simplify" ->
        handle_sympy_operation(&SympyMcp.SympyTools.simplify/1, [args["expression"]], "simplify expression", state)

      "sympy_differentiate" ->
        handle_sympy_operation(
          &SympyMcp.SympyTools.differentiate/2,
          [args["expression"], args["variable"]],
          "differentiate expression",
          state
        )

      "sympy_integrate" ->
        handle_sympy_operation(
          &SympyMcp.SympyTools.integrate/2,
          [args["expression"], args["variable"]],
          "integrate expression",
          state
        )

      "sympy_expand" ->
        handle_sympy_operation(&SympyMcp.SympyTools.expand/1, [args["expression"]], "expand expression", state)

      "sympy_factor" ->
        handle_sympy_operation(&SympyMcp.SympyTools.factor/1, [args["expression"]], "factor expression", state)

      "sympy_evaluate" ->
        substitutions = Map.get(args, "substitutions", %{})

        handle_sympy_operation(
          &SympyMcp.SympyTools.evaluate/2,
          [args["expression"], substitutions],
          "evaluate expression",
          state
        )

      "sympy_list_operations" ->
        handle_list_operations(state)

      _ ->
        {:error, "Tool not found: #{tool_name}", state}
    end
  end

  defp handle_list_operations(state) do
    operations = [
      "sympy_solve",
      "sympy_simplify",
      "sympy_differentiate",
      "sympy_integrate",
      "sympy_expand",
      "sympy_factor",
      "sympy_evaluate"
    ]

    body = Jason.encode!(%{"operations" => operations})
    {:ok, %{"content" => [%{"type" => "text", "text" => body}], "isError" => false}, state}
  end

  defp handle_sympy_operation(function, args, operation_description, state) do
    case apply(function, args) do
      {:ok, result} ->
        text = format_sympy_result(operation_description, result)
        {:ok, %{"content" => [%{"type" => "text", "text" => text}], "isError" => false}, state}

      {:error, reason} ->
        {:error, "Failed to #{operation_description}: #{reason}", state}
    end
  end

  defp format_sympy_result(operation_description, result) when is_list(result) do
    # solve returns a list of solution strings; show them clearly
    formatted = Enum.join(result, ", ")
    "#{String.capitalize(operation_description)} result: #{formatted}"
  end

  defp format_sympy_result(operation_description, result) do
    "#{String.capitalize(operation_description)} result: #{result}"
  end
end
