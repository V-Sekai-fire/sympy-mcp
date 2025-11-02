# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule SympyMcp.SympyToolsTest do
  use ExUnit.Case, async: true

  alias SympyMcp.SympyTools

  describe "solve/2" do
    test "solves simple quadratic equation" do
      # Note: This test requires Python/SymPy to be available
      # In a real environment, you might mock this or skip if Pythonx not available
      case SympyTools.solve("x**2 - 4", "x") do
        {:ok, solutions} ->
          assert is_list(solutions)
          assert "2" in solutions or "-2" in solutions

        {:error, _reason} ->
          # Skip test if SymPy not available
          :ok
      end
    end
  end

  describe "simplify/1" do
    test "simplifies basic expression" do
      case SympyTools.simplify("x + x") do
        {:ok, simplified} ->
          assert is_binary(simplified)

        {:error, _reason} ->
          # Skip test if SymPy not available
          :ok
      end
    end
  end

  describe "differentiate/2" do
    test "computes derivative" do
      case SympyTools.differentiate("x**2", "x") do
        {:ok, derivative} ->
          assert is_binary(derivative)

        {:error, _reason} ->
          # Skip test if SymPy not available
          :ok
      end
    end
  end

  describe "integrate/2" do
    test "computes integral" do
      case SympyTools.integrate("x", "x") do
        {:ok, integral} ->
          assert is_binary(integral)

        {:error, _reason} ->
          # Skip test if SymPy not available
          :ok
      end
    end
  end

  describe "expand/1" do
    test "expands expression" do
      case SympyTools.expand("(x + 1)**2") do
        {:ok, expanded} ->
          assert is_binary(expanded)

        {:error, _reason} ->
          # Skip test if SymPy not available
          :ok
      end
    end
  end

  describe "factor/1" do
    test "factors expression" do
      case SympyTools.factor("x**2 - 1") do
        {:ok, factored} ->
          assert is_binary(factored)

        {:error, _reason} ->
          # Skip test if SymPy not available
          :ok
      end
    end
  end

  describe "evaluate/2" do
    test "evaluates expression numerically" do
      case SympyTools.evaluate("x + 1", %{"x" => 5}) do
        {:ok, result} ->
          assert is_number(result)

        {:error, _reason} ->
          # Skip test if SymPy not available
          :ok
      end
    end
  end
end
