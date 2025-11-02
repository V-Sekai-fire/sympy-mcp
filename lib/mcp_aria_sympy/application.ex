# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule MCP.AriaSympy.Application do
  @moduledoc false

  use Application

  @spec start(:normal | :permanent | :transient, any()) :: {:ok, pid()}
  @impl true
  def start(_type, _args) do
    # Ensure Pythonx is started for SymPy support
    Application.ensure_all_started(:pythonx)

    children = [
      {MCP.AriaSympy.NativeService, [name: MCP.AriaSympy.NativeService]},
      {MCP.AriaSympy.StdioServer, []}
    ]

    opts = [strategy: :one_for_one, name: MCP.AriaSympy.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
