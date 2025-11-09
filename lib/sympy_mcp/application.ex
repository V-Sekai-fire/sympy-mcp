# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule SympyMcp.Application do
  @moduledoc false

  use Application

  @spec start(:normal | :permanent | :transient, any()) :: {:ok, pid()}
  @impl true
  def start(_type, _args) do
    # Ensure Pythonx is started for SymPy support
    Application.ensure_all_started(:pythonx)

    # Determine transport based on environment
    transport = get_transport()

    children =
      case transport do
        :http ->
          [
            {SympyMcp.NativeService, [name: SympyMcp.NativeService]},
            {SympyMcp.HttpServer, []}
          ]

        :stdio ->
          [
            {SympyMcp.NativeService, [name: SympyMcp.NativeService]},
            {SympyMcp.StdioServer, []}
          ]
      end

    opts = [strategy: :one_for_one, name: SympyMcp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp get_transport do
    case System.get_env("MCP_TRANSPORT") do
      "http" -> :http
      "stdio" -> :stdio
      _ ->
        # Default to http if PORT is set (Smithery deployment), otherwise stdio
        if System.get_env("PORT"), do: :http, else: :stdio
    end
  end
end
