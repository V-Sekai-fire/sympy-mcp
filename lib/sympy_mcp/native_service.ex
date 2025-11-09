# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule SympyMcp.NativeService do
  @moduledoc """
  Native BEAM service for SymPy MCP using ex_mcp library.
  Provides symbolic mathematics tools via MCP protocol.
  """

  # Suppress warnings from ex_mcp DSL generated code
  @compile {:no_warn_undefined, :no_warn_pattern}

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

    tool_annotations(%{
      readOnlyHint: true,
      destructiveHint: false,
      idempotentHint: true
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

    tool_annotations(%{
      readOnlyHint: true,
      destructiveHint: false,
      idempotentHint: true
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

    tool_annotations(%{
      readOnlyHint: true,
      destructiveHint: false,
      idempotentHint: true
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

    tool_annotations(%{
      readOnlyHint: true,
      destructiveHint: false,
      idempotentHint: true
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

    tool_annotations(%{
      readOnlyHint: true,
      destructiveHint: false,
      idempotentHint: true
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

    tool_annotations(%{
      readOnlyHint: true,
      destructiveHint: false,
      idempotentHint: true
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

    tool_annotations(%{
      readOnlyHint: true,
      destructiveHint: false,
      idempotentHint: true
    })
  end

  # Define prompts
  defprompt "symbolic_math_helper" do
    meta do
      name("Symbolic Math Helper")
      description("Helps users perform symbolic mathematics operations with SymPy")
    end

    arguments do
      arg :operation, required: true, description: "The mathematical operation to perform (solve, simplify, differentiate, integrate, expand, factor, or evaluate)"
      arg :expression, required: true, description: "The mathematical expression to work with"
      arg :variable, description: "The variable to use (required for solve, differentiate, and integrate operations)"
      arg :substitutions, description: "Variable substitutions for evaluation (JSON object)"
    end
  end

  # Define resources
  defresource "sympy://examples" do
    meta do
      name("SymPy Example Expressions")
      description("Common example expressions for testing SymPy operations")
    end

    mime_type "application/json"
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

  # Prompt handler
  @impl true
  def handle_prompt_get("symbolic_math_helper", args, state) do
    operation = Map.get(args, "operation", "simplify")
    expression = Map.get(args, "expression", "")
    variable = Map.get(args, "variable")
    substitutions = Map.get(args, "substitutions")

    # Build guidance based on operation
    guidance = case operation do
      "solve" ->
        "To solve the equation #{expression} for #{variable || "a variable"}, use the sympy_solve tool with the equation and variable parameters."
      "simplify" ->
        "To simplify the expression #{expression}, use the sympy_simplify tool with the expression parameter."
      "differentiate" ->
        "To differentiate #{expression} with respect to #{variable || "a variable"}, use the sympy_differentiate tool with the expression and variable parameters."
      "integrate" ->
        "To integrate #{expression} with respect to #{variable || "a variable"}, use the sympy_integrate tool with the expression and variable parameters."
      "expand" ->
        "To expand the expression #{expression}, use the sympy_expand tool with the expression parameter."
      "factor" ->
        "To factor the expression #{expression}, use the sympy_factor tool with the expression parameter."
      "evaluate" ->
        subs_text = if substitutions, do: " with substitutions #{substitutions}", else: ""
        "To evaluate #{expression}#{subs_text}, use the sympy_evaluate tool with the expression#{if substitutions, do: " and substitutions", else: ""} parameters."
      _ ->
        "Available operations: solve, simplify, differentiate, integrate, expand, factor, and evaluate. Use the appropriate tool for your operation."
    end

    messages = [
      system("You are a helpful assistant for symbolic mathematics using SymPy. Guide users on how to use the available tools."),
      user("I want to #{operation} the expression: #{expression}#{if variable, do: " with variable #{variable}", else: ""}"),
      assistant("#{guidance}\n\nAll SymPy tools are read-only, non-destructive, and idempotent - you can safely call them multiple times with the same inputs.")
    ]

    {:ok, %{messages: messages}, state}
  end

  # Resource handler
  @impl true
  def handle_resource_read("sympy://examples", _uri, state) do
    examples = %{
      "basic_expressions" => [
        "x**2 + 2*x + 1",
        "sin(x) + cos(x)",
        "exp(x) * log(x)"
      ],
      "equations" => [
        "x**2 - 4 = 0",
        "x**2 + y**2 = 1",
        "x**3 - 1 = 0"
      ],
      "derivatives" => [
        "x**2",
        "sin(x)",
        "exp(x) * log(x)"
      ],
      "integrals" => [
        "x**2",
        "1/x",
        "exp(-x**2)"
      ]
    }

    content = [
      text("""
      SymPy Example Expressions

      These are common expressions you can use to test SymPy operations:

      Basic Expressions:
      #{Enum.join(examples["basic_expressions"], "\n      ")}

      Equations (for solving):
      #{Enum.join(examples["equations"], "\n      ")}

      Expressions for Differentiation:
      #{Enum.join(examples["derivatives"], "\n      ")}

      Expressions for Integration:
      #{Enum.join(examples["integrals"], "\n      ")}

      Use these examples with the appropriate SymPy tools to perform symbolic mathematics operations.
      """)
    ]

    {:ok, content, state}
  end
end
