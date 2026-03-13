# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule Mix.Tasks.Mcp.Server do
  @moduledoc """
  Mix task to run the MCP Aria SymPy server.

  This task starts the MCP server that provides symbolic mathematics
  capabilities via the Model Context Protocol.

  ## Usage

      mix mcp.server

  The server listens on HTTP (streaming). Set PORT (default 8081) and HOST. Runs until stopped.
  """

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")

    # Start the MCP application
    Application.ensure_all_started(:sympy_mcp)

    # Keep the process running
    Process.sleep(:infinity)
  end
end
