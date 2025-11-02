# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule SympyMcp.ToolDefinitions do
  @moduledoc """
  Tool definitions for MCP Aria SymPy server.
  Defines all available SymPy tools with their schemas.
  """

  defmacro define_tools do
    quote do
      # SymPy Tools
      deftool "sympy_solve" do
        meta do
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
    end
  end
end
