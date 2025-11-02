# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule Mix.Tasks.Mcp.Server do
  @moduledoc """
  Mix task to run the MCP Aria SymPy server.

  This task starts the MCP server that provides symbolic mathematics
  capabilities via the Model Context Protocol.

  ## Usage

      mix mcp.server

  The server will run indefinitely, communicating via stdio for MCP protocol.
  """

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")

    # Start the MCP application
    Application.ensure_all_started(:mcp_aria_sympy)

    # Keep the process running
    Process.sleep(:infinity)
  end
end
