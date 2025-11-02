# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule SympyMcp.NativeServiceTest do
  use ExUnit.Case, async: true

  alias SympyMcp.NativeService

  describe "handle_tool_call/3" do
    test "handles sympy_solve tool call" do
      args = %{"equation" => "x**2 - 4", "variable" => "x"}
      state = %{}

      case NativeService.handle_tool_call("sympy_solve", args, state) do
        {:ok, result, new_state} ->
          assert is_map(result)
          assert Map.has_key?(result, :content)
          assert new_state == state

        {:error, _reason, new_state} ->
          assert new_state == state
      end
    end

    test "handles sympy_simplify tool call" do
      args = %{"expression" => "x + x"}
      state = %{}

      case NativeService.handle_tool_call("sympy_simplify", args, state) do
        {:ok, result, new_state} ->
          assert is_map(result)
          assert Map.has_key?(result, :content)
          assert new_state == state

        {:error, _reason, new_state} ->
          assert new_state == state
      end
    end

    test "handles unknown tool" do
      args = %{}
      state = %{}

      result = NativeService.handle_tool_call("unknown_tool", args, state)
      assert {:error, "Tool not found: unknown_tool", state} == result
    end
  end
end
