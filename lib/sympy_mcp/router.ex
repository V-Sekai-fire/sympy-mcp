# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule SympyMcp.Router do
  @moduledoc """
  Router for SymPy MCP HTTP server.
  Adds health check endpoint and forwards MCP requests to ExMCP.HttpPlug.
  """

  use Plug.Router

  plug :match
  plug :dispatch

  # Health check endpoint for Docker/Smithery
  get "/health" do
    send_resp(conn, 200, Jason.encode!(%{status: "ok"}))
  end

  # Forward all other requests to ExMCP.HttpPlug
  forward "/", to: ExMCP.HttpPlug, init_opts: [
    handler: SympyMcp.NativeService,
    server_info: %{
      name: "SymPy MCP Server",
      version: "0.1.0"
    },
    sse_enabled: true,
    cors_enabled: true
  ]

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

