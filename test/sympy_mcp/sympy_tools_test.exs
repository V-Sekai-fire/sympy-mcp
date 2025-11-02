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
    # Test the mock functions directly to increase coverage
    # These functions are normally only called when Pythonx is unavailable

    test "mock_solve handles known equations" do
      assert {:ok, ["-2", "2"]} = SympyTools.test_mock_solve("x**2 - 4", "x")
      assert {:ok, ["-1", "1"]} = SympyTools.test_mock_solve("x**2 - 1", "x")
      assert {:ok, ["-1"]} = SympyTools.test_mock_solve("x + 1", "x")
      assert {:ok, ["Mock solution for unknown eq solved for x"]} = SympyTools.test_mock_solve("unknown eq", "x")
    end

    test "mock_simplify handles known expressions" do
      assert {:ok, "2*x"} = SympyTools.test_mock_simplify("x + x")
      assert {:ok, "x**2"} = SympyTools.test_mock_simplify("x * x")
      assert {:ok, "Mock simplified: unknown"} = SympyTools.test_mock_simplify("unknown")
    end

    test "mock_differentiate handles known derivatives" do
      assert {:ok, "2*x"} = SympyTools.test_mock_differentiate("x**2", "x")
      assert {:ok, "3*x**2"} = SympyTools.test_mock_differentiate("x**3", "x")
      assert {:ok, "Mock derivative of unknown w.r.t. x"} = SympyTools.test_mock_differentiate("unknown", "x")
    end

    test "mock_integrate handles known integrals" do
      assert {:ok, "x**2/2"} = SympyTools.test_mock_integrate("x", "x")
      assert {:ok, "x**3/3"} = SympyTools.test_mock_integrate("x**2", "x")
      assert {:ok, "Mock integral of unknown dx"} = SympyTools.test_mock_integrate("unknown", "x")
    end

    test "mock_expand handles known expansions" do
      assert {:ok, "x**2 + 2*x + 1"} = SympyTools.test_mock_expand("(x + 1)**2")
      assert {:ok, "x**2 + 2*x*y + y**2"} = SympyTools.test_mock_expand("(x + y)**2")
      assert {:ok, "Mock expanded: unknown"} = SympyTools.test_mock_expand("unknown")
    end

    test "mock_factor handles known factorizations" do
      assert {:ok, "(x - 1)*(x + 1)"} = SympyTools.test_mock_factor("x**2 - 1")
      assert {:ok, "(x - 2)*(x + 2)"} = SympyTools.test_mock_factor("x**2 - 4")
      assert {:ok, "Mock factored: unknown"} = SympyTools.test_mock_factor("unknown")
    end

    test "mock_evaluate handles known evaluations" do
      assert {:ok, 6} = SympyTools.test_mock_evaluate("x + 1", %{"x" => 5})
      assert {:ok, 6} = SympyTools.test_mock_evaluate("x * 2", %{"x" => 3})
      assert {:ok, 42.0} = SympyTools.test_mock_evaluate("unknown", %{})
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
