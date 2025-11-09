# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule SympyMcp.Router do
  @moduledoc """
  Router for SymPy MCP HTTP server.
  Mounts the MCP endpoint at /mcp as required by Smithery.
  """

  use Plug.Router

  plug :match
  plug :dispatch

  # Mount MCP handler at /mcp endpoint
  forward "/mcp", to: ExMCP.HttpPlug, init_opts: get_plug_opts()

  # Health check endpoint
  match _ do
    send_resp(conn, 404, "Not Found")
  end

  defp get_plug_opts do
    server_info = %{
      name: "SymPy MCP Server",
      version: "0.1.0"
    }

    [
      handler: SympyMcp.NativeService,
      server_info: server_info,
      sse_enabled: true,
      cors_enabled: true
    ]
  end
end

