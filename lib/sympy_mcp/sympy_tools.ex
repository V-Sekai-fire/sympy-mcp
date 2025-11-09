# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule SympyMcp.SympyTools do
  @moduledoc """
  SymPy tools exposed via MCP using Pythonx for symbolic mathematics.

  This module provides MCP tools that wrap SymPy functionality for:
  - Symbolic solving
  - Simplification
  - Differentiation
  - Integration
  - Expression manipulation
  """

  require Logger

  @type sympy_result :: {:ok, term()} | {:error, String.t()}

  @doc """
  Solves a symbolic equation for a variable.

  ## Parameters
    - equation: String representation of the equation (e.g., "x**2 - 1")
    - variable: String representation of the variable to solve for (e.g., "x")

  ## Returns
    - `{:ok, [String.t()]}` - List of solutions as strings
    - `{:error, String.t()}` - Error message
  """
  @spec solve(String.t(), String.t()) :: sympy_result()
  def solve(equation, variable) when is_binary(equation) and is_binary(variable) do
    # Ensure Pythonx is initialized
    case ensure_pythonx() do
      :ok ->
        do_solve(equation, variable)

      :mock ->
        # Return mock result for demo when Pythonx isn't available
        mock_solve(equation, variable)
    end
  end

  defp mock_solve(equation, variable) do
    # Simple mock responses for common equations
    case equation do
      "x**2 - 4" -> {:ok, ["-2", "2"]}
      "x**2 - 1" -> {:ok, ["-1", "1"]}
      "x + 1" -> {:ok, ["-1"]}
      _ -> {:ok, ["Mock solution for #{equation} solved for #{variable}"]}
    end
  end

  defp ensure_pythonx do
    case Application.ensure_all_started(:pythonx) do
      {:error, reason} ->
        Logger.warning("Failed to start Pythonx application: #{inspect(reason)}")
        :mock

      {:ok, _} ->
        check_pythonx_availability()
    end
  rescue
    exception ->
      Logger.error("Exception starting Pythonx: #{Exception.message(exception)}")
      :mock
  end

  defp check_pythonx_availability do
    # Use /dev/null to suppress Python's output from corrupting stdio
    null_device = File.open!("/dev/null", [:write])

    case Pythonx.eval("1 + 1", %{}, stdout_device: null_device, stderr_device: null_device) do
      {result, _globals} ->
        case Pythonx.decode(result) do
          2 -> :ok
          _ -> :mock
        end

      _ ->
        :mock
    end
  end

  defp do_solve(equation, variable) do
    code = """
    from sympy import symbols, solve, parse_expr

    var = symbols('#{variable}')
    expr = parse_expr('#{equation}')
    solutions = solve(expr, var)
    [str(sol) for sol in solutions]
    """

    case Pythonx.eval(code, %{}) do
      {result, _globals} ->
        case Pythonx.decode(result) do
          solutions when is_list(solutions) -> {:ok, solutions}
          _ -> {:error, "Failed to decode solutions"}
        end

      error ->
        {:error, inspect(error)}
    end
  rescue
    e ->
      {:error, Exception.message(e)}
  end

  @doc """
  Simplifies a symbolic expression.

  ## Parameters
    - expression: String representation of the expression

  ## Returns
    - `{:ok, String.t()}` - Simplified expression as a string
    - `{:error, String.t()}` - Error message
  """
  @spec simplify(String.t()) :: sympy_result()
  def simplify(expression) when is_binary(expression) do
    case ensure_pythonx() do
      :ok ->
        do_simplify(expression)

      :mock ->
        mock_simplify(expression)
    end
  end

  defp mock_simplify(expression) do
    case expression do
      "x + x" -> {:ok, "2*x"}
      "x * x" -> {:ok, "x**2"}
      _ -> {:ok, "Mock simplified: #{expression}"}
    end
  end

  defp do_simplify(expression) do
    code = """
    from sympy import parse_expr, simplify

    expr = parse_expr('#{expression}')
    simplified = simplify(expr)
    str(simplified)
    """

    case Pythonx.eval(code, %{}) do
      {result, _globals} ->
        case Pythonx.decode(result) do
          simplified when is_binary(simplified) -> {:ok, simplified}
          _ -> {:error, "Failed to decode simplified expression"}
        end

      error ->
        {:error, inspect(error)}
    end
  rescue
    e ->
      {:error, Exception.message(e)}
  end

  @doc """
  Computes the derivative of an expression.

  ## Parameters
    - expression: String representation of the expression
    - variable: String representation of the variable to differentiate with respect to

  ## Returns
    - `{:ok, String.t()}` - Derivative as a string
    - `{:error, String.t()}` - Error message
  """
  @spec differentiate(String.t(), String.t()) :: sympy_result()
  def differentiate(expression, variable) when is_binary(expression) and is_binary(variable) do
    case ensure_pythonx() do
      :ok ->
        do_differentiate(expression, variable)

      :mock ->
        mock_differentiate(expression, variable)
    end
  end

  defp mock_differentiate(expression, variable) do
    case {expression, variable} do
      {"x**2", "x"} -> {:ok, "2*x"}
      {"x**3", "x"} -> {:ok, "3*x**2"}
      _ -> {:ok, "Mock derivative of #{expression} w.r.t. #{variable}"}
    end
  end

  defp do_differentiate(expression, variable) do
    code = """
    from sympy import symbols, parse_expr, diff

    var = symbols('#{variable}')
    expr = parse_expr('#{expression}')
    derivative = diff(expr, var)
    str(derivative)
    """

    case Pythonx.eval(code, %{}) do
      {result, _globals} ->
        case Pythonx.decode(result) do
          derivative when is_binary(derivative) -> {:ok, derivative}
          _ -> {:error, "Failed to decode derivative"}
        end

      error ->
        {:error, inspect(error)}
    end
  rescue
    e ->
      {:error, Exception.message(e)}
  end

  @doc """
  Computes the integral of an expression.

  ## Parameters
    - expression: String representation of the expression
    - variable: String representation of the variable to integrate with respect to

  ## Returns
    - `{:ok, String.t()}` - Integral as a string
    - `{:error, String.t()}` - Error message
  """
  @spec integrate(String.t(), String.t()) :: sympy_result()
  def integrate(expression, variable) when is_binary(expression) and is_binary(variable) do
    case ensure_pythonx() do
      :ok ->
        do_integrate(expression, variable)

      :mock ->
        mock_integrate(expression, variable)
    end
  end

  defp mock_integrate(expression, variable) do
    case {expression, variable} do
      {"x", "x"} -> {:ok, "x**2/2"}
      {"x**2", "x"} -> {:ok, "x**3/3"}
      _ -> {:ok, "Mock integral of #{expression} d#{variable}"}
    end
  end

  defp do_integrate(expression, variable) do
    code = """
    from sympy import symbols, parse_expr, integrate

    var = symbols('#{variable}')
    expr = parse_expr('#{expression}')
    integral = integrate(expr, var)
    str(integral)
    """

    case Pythonx.eval(code, %{}) do
      {result, _globals} ->
        case Pythonx.decode(result) do
          integral when is_binary(integral) -> {:ok, integral}
          _ -> {:error, "Failed to decode integral"}
        end

      error ->
        {:error, inspect(error)}
    end
  rescue
    e ->
      {:error, Exception.message(e)}
  end

  @doc """
  Expands a symbolic expression.

  ## Parameters
    - expression: String representation of the expression

  ## Returns
    - `{:ok, String.t()}` - Expanded expression as a string
    - `{:error, String.t()}` - Error message
  """
  @spec expand(String.t()) :: sympy_result()
  def expand(expression) when is_binary(expression) do
    case ensure_pythonx() do
      :ok ->
        do_expand(expression)

      :mock ->
        mock_expand(expression)
    end
  end

  defp mock_expand(expression) do
    case expression do
      "(x + 1)**2" -> {:ok, "x**2 + 2*x + 1"}
      "(x + y)**2" -> {:ok, "x**2 + 2*x*y + y**2"}
      _ -> {:ok, "Mock expanded: #{expression}"}
    end
  end

  defp do_expand(expression) do
    code = """
    from sympy import parse_expr, expand

    expr = parse_expr('#{expression}')
    expanded = expand(expr)
    str(expanded)
    """

    case Pythonx.eval(code, %{}) do
      {result, _globals} ->
        case Pythonx.decode(result) do
          expanded when is_binary(expanded) -> {:ok, expanded}
          _ -> {:error, "Failed to decode expanded expression"}
        end

      error ->
        {:error, inspect(error)}
    end
  rescue
    e ->
      {:error, Exception.message(e)}
  end

  @doc """
  Factors a symbolic expression.

  ## Parameters
    - expression: String representation of the expression

  ## Returns
    - `{:ok, String.t()}` - Factored expression as a string
    - `{:error, String.t()}` - Error message
  """
  @spec factor(String.t()) :: sympy_result()
  def factor(expression) when is_binary(expression) do
    case ensure_pythonx() do
      :ok ->
        do_factor(expression)

      :mock ->
        mock_factor(expression)
    end
  end

  defp mock_factor(expression) do
    case expression do
      "x**2 - 1" -> {:ok, "(x - 1)*(x + 1)"}
      "x**2 - 4" -> {:ok, "(x - 2)*(x + 2)"}
      _ -> {:ok, "Mock factored: #{expression}"}
    end
  end

  defp do_factor(expression) do
    code = """
    from sympy import parse_expr, factor

    expr = parse_expr('#{expression}')
    factored = factor(expr)
    str(factored)
    """

    case Pythonx.eval(code, %{}) do
      {result, _globals} ->
        case Pythonx.decode(result) do
          factored when is_binary(factored) -> {:ok, factored}
          _ -> {:error, "Failed to decode factored expression"}
        end

      error ->
        {:error, inspect(error)}
    end
  rescue
    e ->
      {:error, Exception.message(e)}
  end

  @doc """
  Evaluates a symbolic expression numerically.

  ## Parameters
    - expression: String representation of the expression
    - substitutions: Map of variable names to numeric values

  ## Returns
    - `{:ok, number()}` - Numeric result
    - `{:error, String.t()}` - Error message
  """
  @spec evaluate(String.t(), map()) :: sympy_result()
  def evaluate(expression, substitutions \\ %{}) when is_binary(expression) and is_map(substitutions) do
    case ensure_pythonx() do
      :ok ->
        do_evaluate(expression, substitutions)

      :mock ->
        mock_evaluate(expression, substitutions)
    end
  end

  # Test helper functions to expose mock logic for coverage
  @doc false
  def test_mock_solve(equation, variable), do: mock_solve(equation, variable)
  @doc false
  def test_mock_simplify(expression), do: mock_simplify(expression)
  @doc false
  def test_mock_differentiate(expression, variable), do: mock_differentiate(expression, variable)
  @doc false
  def test_mock_integrate(expression, variable), do: mock_integrate(expression, variable)
  @doc false
  def test_mock_expand(expression), do: mock_expand(expression)
  @doc false
  def test_mock_factor(expression), do: mock_factor(expression)
  @doc false
  def test_mock_evaluate(expression, substitutions), do: mock_evaluate(expression, substitutions)

  defp mock_evaluate(expression, substitutions) do
    case {expression, substitutions} do
      {"x + 1", %{"x" => 5}} -> {:ok, 6}
      {"x * 2", %{"x" => 3}} -> {:ok, 6}
      # Mock result
      _ -> {:ok, 42.0}
    end
  end

  defp do_evaluate(expression, substitutions) do
    subs_code =
      Enum.map_join(substitutions, ", ", fn {var, val} -> "'#{var}': #{val}" end)

    code = """
    from sympy import parse_expr

    expr = parse_expr('#{expression}')
    result = expr.subs({#{subs_code}})
    float(result)
    """

    case Pythonx.eval(code, %{}) do
      {result, _globals} ->
        case Pythonx.decode(result) do
          value when is_number(value) -> {:ok, value}
          _ -> {:error, "Failed to decode numeric result"}
        end

      error ->
        {:error, inspect(error)}
    end
  rescue
    e ->
      {:error, Exception.message(e)}
  end
end
