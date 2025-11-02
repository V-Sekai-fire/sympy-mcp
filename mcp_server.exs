#!/usr/bin/env elixir

# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

# Minimal MCP Server for Aria SymPy
# This is a standalone implementation that doesn't require external dependencies

defmodule SimpleJSON do
  @moduledoc "Simple JSON encoder/decoder for basic MCP messages"

  def decode(json_string) do
    # Very basic JSON parsing - only handles the MCP messages we need
    json_string
    |> String.trim()
    |> parse_json_value()
  end

  def encode!(map) when is_map(map) do
    encode_map(map)
  end

  def encode!(list) when is_list(list) do
    encode_list(list)
  end

  def encode!(string) when is_binary(string) do
    "\"#{string}\""
  end

  def encode!(number) when is_number(number) do
    to_string(number)
  end

  def encode!(bool) when is_boolean(bool) do
    to_string(bool)
  end

  def encode!(nil), do: "null"

  defp parse_json_value("{" <> rest) do
    parse_object(rest, %{})
  end

  defp parse_json_value("[" <> rest) do
    parse_array(rest, [])
  end

  defp parse_json_value("\"" <> rest) do
    parse_string(rest, "")
  end

  defp parse_json_value("true"), do: {:ok, true}
  defp parse_json_value("false"), do: {:ok, false}
  defp parse_json_value("null"), do: {:ok, nil}
  defp parse_json_value(string) do
    case Integer.parse(string) do
      {int, ""} -> {:ok, int}
      _ ->
        case Float.parse(string) do
          {float, ""} -> {:ok, float}
          _ -> {:error, :invalid_json}
        end
    end
  end

  defp parse_object("}" <> _rest, acc), do: {:ok, acc}
  defp parse_object(str, acc) do
    # Simplified parsing - this is very basic
    {:error, :complex_json}
  end

  defp parse_array("]" <> _rest, acc), do: {:ok, acc}
  defp parse_array(_str, _acc), do: {:error, :complex_json}

  defp parse_string("\"" <> _rest, acc), do: {:ok, acc}
  defp parse_string(<<char::utf8, rest::binary>>, acc), do: parse_string(rest, acc <> <<char>>)

  defp encode_map(map) do
    pairs = Enum.map(map, fn {k, v} -> "\"#{k}\":#{encode!(v)}" end)
    "{#{Enum.join(pairs, ",")}}"
  end

  defp encode_list(list) do
    items = Enum.map(list, &encode!/1)
    "[#{Enum.join(items, ",")}}"
  end
end

defmodule MinimalMCPServer do
  @moduledoc """
  A minimal MCP server implementation for SymPy operations.
  This server handles basic MCP protocol without external dependencies.
  """

  def start do
    IO.puts("Aria SymPy MCP Server starting...")
    IO.puts("Listening for MCP messages on stdin...")

    # Read messages from stdin in a loop
    read_messages()
  end

  defp read_messages do
    case IO.read(:stdio, :line) do
      :eof ->
        IO.puts("EOF received, shutting down...")
        :ok

      {:error, reason} ->
        IO.puts("Error reading stdin: #{inspect(reason)}")
        :error

      line ->
        line = String.trim(line)
        if line == "" do
          read_messages()
        else
          case handle_message(line) do
            :ok -> read_messages()
            :error -> :error
          end
        end
    end
  end

  defp handle_message(json_line) do
    # Simple JSON parsing for basic MCP messages
    case parse_simple_json(json_line) do
      {:ok, %{"method" => "initialize", "id" => id} = _request} ->
        response = %{
          "jsonrpc" => "2.0",
          "id" => id,
          "result" => %{
            "protocolVersion" => "2025-06-18",
            "serverInfo" => %{
              "name" => "Aria SymPy MCP Server",
              "version" => "0.1.0"
            },
            "capabilities" => %{
              "tools" => %{"listChanged" => true}
            }
          }
        }
        IO.puts(Jason.encode!(response))
        :ok

      {:ok, %{"method" => "tools/list", "id" => id} = _request} ->
        tools = [
          %{
            "name" => "sympy_solve",
            "description" => "Solves a symbolic equation for a variable",
            "inputSchema" => %{
              "type" => "object",
              "properties" => %{
                "equation" => %{"type" => "string", "description" => "Equation to solve"},
                "variable" => %{"type" => "string", "description" => "Variable to solve for"}
              },
              "required" => ["equation", "variable"]
            }
          },
          %{
            "name" => "sympy_simplify",
            "description" => "Simplifies a symbolic expression",
            "inputSchema" => %{
              "type" => "object",
              "properties" => %{
                "expression" => %{"type" => "string", "description" => "Expression to simplify"}
              },
              "required" => ["expression"]
            }
          },
          %{
            "name" => "sympy_differentiate",
            "description" => "Computes the derivative of an expression",
            "inputSchema" => %{
              "type" => "object",
              "properties" => %{
                "expression" => %{"type" => "string", "description" => "Expression to differentiate"},
                "variable" => %{"type" => "string", "description" => "Variable to differentiate with respect to"}
              },
              "required" => ["expression", "variable"]
            }
          },
          %{
            "name" => "sympy_integrate",
            "description" => "Computes the integral of an expression",
            "inputSchema" => %{
              "type" => "object",
              "properties" => %{
                "expression" => %{"type" => "string", "description" => "Expression to integrate"},
                "variable" => %{"type" => "string", "description" => "Variable to integrate with respect to"}
              },
              "required" => ["expression", "variable"]
            }
          },
          %{
            "name" => "sympy_expand",
            "description" => "Expands a symbolic expression",
            "inputSchema" => %{
              "type" => "object",
              "properties" => %{
                "expression" => %{"type" => "string", "description" => "Expression to expand"}
              },
              "required" => ["expression"]
            }
          },
          %{
            "name" => "sympy_factor",
            "description" => "Factors a symbolic expression",
            "inputSchema" => %{
              "type" => "object",
              "properties" => %{
                "expression" => %{"type" => "string", "description" => "Expression to factor"}
              },
              "required" => ["expression"]
            }
          },
          %{
            "name" => "sympy_evaluate",
            "description" => "Evaluates an expression numerically",
            "inputSchema" => %{
              "type" => "object",
              "properties" => %{
                "expression" => %{"type" => "string", "description" => "Expression to evaluate"},
                "substitutions" => %{"type" => "object", "description" => "Variable substitutions"}
              },
              "required" => ["expression"]
            }
          }
        ]

        response = %{
          "jsonrpc" => "2.0",
          "id" => id,
          "result" => %{"tools" => tools}
        }
        IO.puts(Jason.encode!(response))
        :ok

      {:ok, %{"method" => "tools/call", "id" => id, "params" => params} = _request} ->
        handle_tool_call(params, id)

      {:ok, _request} ->
        # Unknown method
        error_response = %{
          "jsonrpc" => "2.0",
          "error" => %{
            "code" => -32_601,
            "message" => "Method not found"
          },
          "id" => nil
        }
        IO.puts(Jason.encode!(error_response))
        :ok

      {:error, _reason} ->
        error_response = %{
          "jsonrpc" => "2.0",
          "error" => %{
            "code" => -32_700,
            "message" => "Parse error"
          },
          "id" => nil
        }
        IO.puts(Jason.encode!(error_response))
        :ok
    end
  rescue
    e ->
      error_response = %{
        "jsonrpc" => "2.0",
        "error" => %{
          "code" => -32_603,
          "message" => "Internal error: #{Exception.message(e)}"
        },
        "id" => nil
      }
      IO.puts(Jason.encode!(error_response))
      :ok
  end

  defp handle_tool_call(%{"name" => tool_name} = params, id) do
    result = case tool_name do
      "sympy_solve" ->
        %{"equation" => equation, "variable" => variable} = params["arguments"]
        # Mock response - in real implementation this would call SymPy
        %{"solutions" => ["Mock solution for #{equation} = 0 solved for #{variable}"]}

      "sympy_simplify" ->
        %{"expression" => expression} = params["arguments"]
        %{"simplified" => "Mock simplified: #{expression}"}

      "sympy_differentiate" ->
        %{"expression" => expression, "variable" => variable} = params["arguments"]
        %{"derivative" => "Mock derivative of #{expression} w.r.t. #{variable}"}

      "sympy_integrate" ->
        %{"expression" => expression, "variable" => variable} = params["arguments"]
        %{"integral" => "Mock integral of #{expression} d#{variable}"}

      "sympy_expand" ->
        %{"expression" => expression} = params["arguments"]
        %{"expanded" => "Mock expanded: #{expression}"}

      "sympy_factor" ->
        %{"expression" => expression} = params["arguments"]
        %{"factored" => "Mock factored: #{expression}"}

      "sympy_evaluate" ->
        %{"expression" => expression} = params["arguments"]
        substitutions = Map.get(params["arguments"], "substitutions", %{})
        %{"result" => "Mock evaluation of #{expression} with #{inspect(substitutions)}"}

      _ ->
        nil
    end

    if result do
      response = %{
        "jsonrpc" => "2.0",
        "id" => id,
        "result" => %{"content" => [%{"type" => "text", "text" => Jason.encode!(result)}]}
      }
      IO.puts(Jason.encode!(response))
      :ok
    else
      error_response = %{
        "jsonrpc" => "2.0",
        "error" => %{
          "code" => -32_602,
          "message" => "Tool not found: #{tool_name}"
        },
        "id" => id
      }
      IO.puts(Jason.encode!(error_response))
      :ok
    end
  end
end

# Start the server
MinimalMCPServer.start()
