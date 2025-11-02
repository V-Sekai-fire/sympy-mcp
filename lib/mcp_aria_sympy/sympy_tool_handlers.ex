# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule MCP.AriaSympy.SympyToolHandlers do
  @moduledoc """
  SymPy tool handlers for MCP Aria SymPy server.
  Handles all SymPy symbolic mathematics tool implementations.
  """

  @doc """
  Handles sympy_solve tool call.
  Solves a symbolic equation for a variable.
  """
  def handle_solve(%{"equation" => equation, "variable" => variable}, state) do
    new_state = %{state | prompt_uses: state.prompt_uses + 1}

    case MCP.AriaSympy.SympyTools.solve(equation, variable) do
      {:ok, solutions} ->
        result = %{"content" => [json(%{solutions: solutions})]}
        {:ok, result, new_state}

      {:error, reason} ->
        {:error, "Failed to solve equation: #{reason}", new_state}
    end
  end

  @doc """
  Handles sympy_simplify tool call.
  Simplifies a symbolic expression.
  """
  def handle_simplify(%{"expression" => expression}, state) do
    new_state = %{state | prompt_uses: state.prompt_uses + 1}

    case MCP.AriaSympy.SympyTools.simplify(expression) do
      {:ok, simplified} ->
        result = %{"content" => [json(%{simplified: simplified})]}
        {:ok, result, new_state}

      {:error, reason} ->
        {:error, "Failed to simplify expression: #{reason}", new_state}
    end
  end

  @doc """
  Handles sympy_differentiate tool call.
  Computes the derivative of an expression.
  """
  def handle_differentiate(%{"expression" => expression, "variable" => variable}, state) do
    new_state = %{state | prompt_uses: state.prompt_uses + 1}

    case MCP.AriaSympy.SympyTools.differentiate(expression, variable) do
      {:ok, derivative} ->
        result = %{"content" => [json(%{derivative: derivative})]}
        {:ok, result, new_state}

      {:error, reason} ->
        {:error, "Failed to differentiate expression: #{reason}", new_state}
    end
  end

  @doc """
  Handles sympy_integrate tool call.
  Computes the integral of an expression.
  """
  def handle_integrate(%{"expression" => expression, "variable" => variable}, state) do
    new_state = %{state | prompt_uses: state.prompt_uses + 1}

    case MCP.AriaSympy.SympyTools.integrate(expression, variable) do
      {:ok, integral} ->
        result = %{"content" => [json(%{integral: integral})]}
        {:ok, result, new_state}

      {:error, reason} ->
        {:error, "Failed to integrate expression: #{reason}", new_state}
    end
  end

  @doc """
  Handles sympy_expand tool call.
  Expands a symbolic expression.
  """
  def handle_expand(%{"expression" => expression}, state) do
    new_state = %{state | prompt_uses: state.prompt_uses + 1}

    case MCP.AriaSympy.SympyTools.expand(expression) do
      {:ok, expanded} ->
        result = %{"content" => [json(%{expanded: expanded})]}
        {:ok, result, new_state}

      {:error, reason} ->
        {:error, "Failed to expand expression: #{reason}", new_state}
    end
  end

  @doc """
  Handles sympy_factor tool call.
  Factors a symbolic expression.
  """
  def handle_factor(%{"expression" => expression}, state) do
    new_state = %{state | prompt_uses: state.prompt_uses + 1}

    case MCP.AriaSympy.SympyTools.factor(expression) do
      {:ok, factored} ->
        result = %{"content" => [json(%{factored: factored})]}
        {:ok, result, new_state}

      {:error, reason} ->
        {:error, "Failed to factor expression: #{reason}", new_state}
    end
  end

  @doc """
  Handles sympy_evaluate tool call.
  Evaluates a symbolic expression numerically.
  """
  def handle_evaluate(%{"expression" => expression} = args, state) do
    new_state = %{state | prompt_uses: state.prompt_uses + 1}

    substitutions = Map.get(args, "substitutions", %{})

    case MCP.AriaSympy.SympyTools.evaluate(expression, substitutions) do
      {:ok, result} ->
        response = %{"content" => [json(%{result: result})]}
        {:ok, response, new_state}

      {:error, reason} ->
        {:error, "Failed to evaluate expression: #{reason}", new_state}
    end
  end

  # Helper function for JSON formatting
  defp json(data) do
    %{"type" => "text", "text" => Jason.encode!(data)}
  end
end
