# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule SympyMcp.Router do
  @moduledoc """
  Router for SymPy MCP HTTP server (streamableHttp).
  Health check at /health; all other requests go to ExMCP.HttpPlug with SSE enabled.
  """

  use Plug.Router

  plug :match
  plug :dispatch

  # Health check endpoint for Docker/Smithery
  get "/health" do
    send_resp(conn, 200, Jason.encode!(%{status: "ok"}))
  end

  # Streamable HTTP: ExMCP.HttpPlug with SSE (same pattern as vsekai MCP)
  forward "/",
    to: ExMCP.HttpPlug,
    init_opts: [
      handler: SympyMcp.MCPHandler,
      server_info: %{name: "SymPy MCP Server", version: "1.0.0-dev1"},
      sse_enabled: System.get_env("MCP_SSE_ENABLED") != "false",
      cors_enabled: true,
      oauth_enabled: false
    ]
end
