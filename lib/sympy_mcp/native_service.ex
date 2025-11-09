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
    version: "1.0.0-dev1"

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
      arg(:operation,
        required: true,
        description:
          "The mathematical operation to perform (solve, simplify, differentiate, integrate, expand, factor, or evaluate)"
      )

      arg(:expression, required: true, description: "The mathematical expression to work with")
      arg(:variable, description: "The variable to use (required for solve, differentiate, and integrate operations)")
      arg(:substitutions, description: "Variable substitutions for evaluation (JSON object)")
    end
  end

  # Define resources
  defresource "sympy://examples" do
    meta do
      name("SymPy Example Expressions")
      description("Common example expressions for testing SymPy operations")
    end

    mime_type("application/json")
  end

  # Initialize handler with required configuration schema
  @impl true
  def handle_initialize(params, state) do
    # Validate required configuration
    config = Map.get(params, "config", %{})

    case validate_config(config) do
      {:ok, validated_config} ->
        # Store config in state for use in tool handlers
        new_state = Map.put(state, :config, validated_config)

        # Define required configuration schema (JSON Schema format)
        config_schema = %{
          "$schema" => "http://json-schema.org/draft-07/schema#",
          "title" => "SymPy MCP Server Configuration",
          "type" => "object",
          "properties" => %{
            "timeout_ms" => %{
              "type" => "integer",
              "description" =>
                "Maximum time in milliseconds allowed for SymPy operations. Prevents resource exhaustion and DoS attacks.",
              "minimum" => 100,
              "maximum" => 300_000,
              "examples" => [5_000, 10_000, 30_000]
            }
          },
          "required" => ["timeout_ms"],
          "additionalProperties" => false
        }

        {:ok,
         %{
           protocolVersion: Map.get(params, "protocolVersion", "2025-06-18"),
           serverInfo: %{
             name: "SymPy MCP Server",
             version: "1.0.0-dev1"
           },
           capabilities: %{
             tools: %{},
             resources: %{},
             prompts: %{}
           },
           configSchema: config_schema
         }, new_state}

      {:error, reason} ->
        {:error, "Invalid configuration: #{reason}", state}
    end
  end

  defp validate_config(config) do
    case Map.get(config, "timeout_ms") do
      nil ->
        {:error, "timeout_ms is required"}

      timeout when is_integer(timeout) and timeout >= 100 and timeout <= 300_000 ->
        {:ok, %{timeout_ms: timeout}}

      timeout when is_integer(timeout) ->
        {:error, "timeout_ms must be between 100 and 300000 milliseconds"}

      _ ->
        {:error, "timeout_ms must be an integer"}
    end
  end

  # Tool call handlers
  @impl true
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

      _ ->
        {:error, "Tool not found: #{tool_name}", state}
    end
  end

  # Helper function to reduce code duplication in tool handlers
  defp handle_sympy_operation(function, args, operation_description, state) do
    case apply(function, args) do
      {:ok, result} ->
        {:ok, %{content: [text("#{String.capitalize(operation_description)} result: #{result}")]}, state}

      {:error, reason} ->
        {:error, "Failed to #{operation_description}: #{reason}", state}
    end
  end

  # Prompt handler
  @impl true
  def handle_prompt_get("symbolic_math_helper", args, state) do
    operation = Map.get(args, "operation", "simplify")
    expression = Map.get(args, "expression", "")
    variable = Map.get(args, "variable")
    substitutions = Map.get(args, "substitutions")

    guidance = build_operation_guidance(operation, expression, variable, substitutions)

    messages = [
      system(
        "You are a helpful assistant for symbolic mathematics using SymPy. Guide users on how to use the available tools."
      ),
      user(
        "I want to #{operation} the expression: #{expression}#{if variable, do: " with variable #{variable}", else: ""}"
      ),
      assistant(
        "#{guidance}\n\nAll SymPy tools are read-only, non-destructive, and idempotent - you can safely call them multiple times with the same inputs."
      )
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

  # Prompt handler
  defp build_operation_guidance(operation, expression, variable, substitutions) do
    # Build a map of operation guidance functions for better performance and maintainability
    guidance_map = %{
      "solve" => fn ->
        "To solve the equation #{expression} for #{variable || "a variable"}, use the sympy_solve tool with the equation and variable parameters."
      end,
      "simplify" => fn ->
        "To simplify the expression #{expression}, use the sympy_simplify tool with the expression parameter."
      end,
      "differentiate" => fn ->
        "To differentiate #{expression} with respect to #{variable || "a variable"}, use the sympy_differentiate tool with the expression and variable parameters."
      end,
      "integrate" => fn ->
        "To integrate #{expression} with respect to #{variable || "a variable"}, use the sympy_integrate tool with the expression and variable parameters."
      end,
      "expand" => fn ->
        "To expand the expression #{expression}, use the sympy_expand tool with the expression parameter."
      end,
      "factor" => fn ->
        "To factor the expression #{expression}, use the sympy_factor tool with the expression parameter."
      end,
      "evaluate" => fn ->
        subs_text = if substitutions, do: " with substitutions #{substitutions}", else: ""

        "To evaluate #{expression}#{subs_text}, use the sympy_evaluate tool with the expression#{if substitutions, do: " and substitutions", else: ""} parameters."
      end
    }

    # Use Map.get with a default fallback for unknown operations
    case Map.get(guidance_map, operation) do
      nil ->
        "Available operations: solve, simplify, differentiate, integrate, expand, factor, and evaluate. Use the appropriate tool for your operation."

      guidance_fn ->
        guidance_fn.()
    end
  end
end
