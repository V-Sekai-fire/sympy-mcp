# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule SympyMcp.ToolHandlersTest do
  use ExUnit.Case, async: true

  alias SympyMcp.ToolHandlers

  describe "handle_tool_call/3" do
    test "handles sympy_solve tool call" do
      args = %{"equation" => "x**2 - 4", "variable" => "x"}
      state = %{prompt_uses: 0}

      case ToolHandlers.handle_tool_call("sympy_solve", args, state) do
        {:ok, result, new_state} ->
          assert is_map(result)
          assert Map.has_key?(result, "content")
          assert new_state.prompt_uses == 1

        {:error, _reason, new_state} ->
          assert new_state.prompt_uses == 1
      end
    end

    test "handles sympy_simplify tool call" do
      args = %{"expression" => "x + x"}
      state = %{prompt_uses: 0}

      case ToolHandlers.handle_tool_call("sympy_simplify", args, state) do
        {:ok, result, new_state} ->
          assert is_map(result)
          assert Map.has_key?(result, "content")
          assert new_state.prompt_uses == 1

        {:error, _reason, new_state} ->
          assert new_state.prompt_uses == 1
      end
    end

    test "handles unknown tool" do
      args = %{}
      state = %{}

      result = ToolHandlers.handle_tool_call("unknown_tool", args, state)
      assert {:error, "Tool not found: unknown_tool", state} == result
    end
  end
end
