# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule MCP.AriaSympy.NativeService do
  @moduledoc """
  Native BEAM service for MCP.AriaSympy using ex_mcp library.
  Main server module that coordinates tool handlers.
  """

  use ExMCP.Server,
    name: "Aria SymPy MCP Server",
    version: "0.1.0"

  require MCP.AriaSympy.ToolDefinitions

  alias MCP.AriaSympy.ToolHandlers

  @type state() :: map()

  # Import tool definitions
  MCP.AriaSympy.ToolDefinitions.define_tools()

  # Callbacks

  @impl true
  def init(_args) do
    require Logger

    Logger.info("Aria SymPy MCP Server initialized")

    {:ok,
     %{
       prompt_uses: 0,
       subscriptions: [],
       created_resources: %{},
       pending_requests: %{},
       cancelled_requests: MapSet.new()
     }}
  end

  @impl true
  def handle_tool_call(tool_name, args, state) do
    ToolHandlers.handle_tool_call(tool_name, args, state)
  end

  @impl true
  def handle_initialize(params, state) do
    client_version = Map.get(params, "protocolVersion", "2025-06-18")

    result = %{
      "protocolVersion" => client_version,
      "serverInfo" => %{"name" => "Aria SymPy MCP Server", "version" => "0.1.0"},
      "capabilities" => %{
        "tools" => %{"listChanged" => true},
        "resources" => %{"listChanged" => true, "subscribe" => true},
        "prompts" => %{}
      }
    }

    new_state = Map.put(state, :protocol_version, client_version)
    {:ok, result, new_state}
  end

  # GenServer callbacks for HTTP handler integration
  def handle_call({:process_request, request}, _from, state) do
    require Logger
    Logger.debug("Processing request: #{inspect(request)}")

    method = Map.get(request, "method")
    params = Map.get(request, "params", %{})
    id = Map.get(request, "id")

    response =
      case method do
        "initialize" ->
          case handle_initialize(params, state) do
            {:ok, result, new_state} ->
              {:ok, %{"jsonrpc" => "2.0", "result" => result, "id" => id}, new_state}

            {:error, reason, new_state} ->
              {:ok, %{"jsonrpc" => "2.0", "error" => %{"code" => -32_603, "message" => reason}, "id" => id}, new_state}

            other ->
              {:ok,
               %{
                 "jsonrpc" => "2.0",
                 "error" => %{"code" => -32_603, "message" => "Initialize failed: #{inspect(other)}"},
                 "id" => id
               }, state}
          end

        "tools/list" ->
          tools_map = get_tools()

          tools =
            Enum.map(tools_map, fn {name, tool_def} ->
              %{
                "name" => name,
                "description" => tool_def.description,
                "inputSchema" => tool_def.input_schema
              }
            end)

          {:ok, %{"jsonrpc" => "2.0", "result" => %{"tools" => tools}, "id" => id}, state}

        "resources/list" ->
          resources = []
          {:ok, %{"jsonrpc" => "2.0", "result" => %{"resources" => resources}, "id" => id}, state}

        "tools/call" ->
          tool_name = Map.get(params, "name")
          tool_args = Map.get(params, "arguments", %{})

          case handle_tool_call(tool_name, tool_args, state) do
            {:ok, result, new_state} ->
              {:ok, %{"jsonrpc" => "2.0", "result" => result, "id" => id}, new_state}

            {:error, reason, new_state} ->
              {:ok, %{"jsonrpc" => "2.0", "error" => %{"code" => -32_603, "message" => reason}, "id" => id}, new_state}
          end

        _ ->
          {:ok, %{"jsonrpc" => "2.0", "error" => %{"code" => -32_601, "message" => "Method not found"}, "id" => id},
           state}
      end

    case response do
      {:ok, resp, new_state} -> {:reply, {:ok, resp}, new_state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:get_protocol_version}, _from, state) do
    version = Map.get(state, :protocol_version, nil)
    {:reply, version, state}
  end
end
