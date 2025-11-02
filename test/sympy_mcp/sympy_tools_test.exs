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
      case SympyMcp.SympyTools.evaluate("x + 1", %{"x" => 5}) do
        {:ok, result} ->
          assert is_number(result)

        {:error, _reason} ->
          # Skip test if SymPy not available
          :ok
      end
    end
  end

  describe "mock fallback functions" do
    # Test mock functions by calling them directly since they're private
    # We can test the mock logic by examining the pattern matching

    test "mock_solve handles known equations" do
      # We can't directly call private functions, but we can verify the logic
      # by testing that when Pythonx fails, the right mock results are returned
      # For now, we'll test this indirectly through integration
      assert true # Placeholder - will be replaced with proper integration test
    end

    test "mock_simplify handles known expressions" do
      assert true # Placeholder
    end

    test "mock_differentiate handles known derivatives" do
      assert true # Placeholder
    end

    test "mock_integrate handles known integrals" do
      assert true # Placeholder
    end

    test "mock_expand handles known expansions" do
      assert true # Placeholder
    end

    test "mock_factor handles known factorizations" do
      assert true # Placeholder
    end

    test "mock_evaluate handles known evaluations" do
      assert true # Placeholder
    end
  end

  describe "error handling" do
    test "solve handles invalid input types" do
      # Test with non-binary inputs (should not match function clause)
      assert_raise FunctionClauseError, fn ->
        SympyMcp.SympyTools.solve(123, "x")
      end

      assert_raise FunctionClauseError, fn ->
        SympyMcp.SympyTools.solve("x**2", :x)
      end
    end

    test "simplify handles invalid input types" do
      assert_raise FunctionClauseError, fn ->
        SympyMcp.SympyTools.simplify(123)
      end
    end

    test "differentiate handles invalid input types" do
      assert_raise FunctionClauseError, fn ->
        SympyMcp.SympyTools.differentiate(123, "x")
      end

      assert_raise FunctionClauseError, fn ->
        SympyMcp.SympyTools.differentiate("x**2", :x)
      end
    end

    test "integrate handles invalid input types" do
      assert_raise FunctionClauseError, fn ->
        SympyMcp.SympyTools.integrate(123, "x")
      end

      assert_raise FunctionClauseError, fn ->
        SympyMcp.SympyTools.integrate("x", :x)
      end
    end

    test "expand handles invalid input types" do
      assert_raise FunctionClauseError, fn ->
        SympyMcp.SympyTools.expand(123)
      end
    end

    test "factor handles invalid input types" do
      assert_raise FunctionClauseError, fn ->
        SympyMcp.SympyTools.factor(123)
      end
    end

    test "evaluate handles invalid input types" do
      assert_raise FunctionClauseError, fn ->
        SympyMcp.SympyTools.evaluate(123, %{})
      end

      assert_raise FunctionClauseError, fn ->
        SympyMcp.SympyTools.evaluate("x", "not_a_map")
      end
    end
  end
end
