# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule SympyMcp.Application do
  @moduledoc """
  Application supervisor for SymPy MCP Server.
  Starts HTTP streaming transport only (no stdio). Use PORT / HOST to configure.
  """

  use Application

  @spec start(:normal | :permanent | :transient, any()) :: {:ok, pid()}
  @impl true
  def start(_type, _args) do
    Application.ensure_all_started(:pythonx)

    port = get_port()
    host = get_host()

    children = [
      {SympyMcp.NativeService, [name: SympyMcp.NativeService]},
      {SympyMcp.HttpServer, [port: port, host: host]}
    ]

    opts = [strategy: :one_for_one, name: SympyMcp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp get_port do
    case System.get_env("PORT") do
      nil -> 8081
      port_str -> String.to_integer(port_str)
    end
  end

  defp get_host do
    case System.get_env("HOST") do
      nil -> if System.get_env("PORT"), do: "0.0.0.0", else: "localhost"
      host -> host
    end
  end
end
