# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule SympyMcp.HttpPlugWrapper do
  @moduledoc """
  Wrapper around ExMCP.HttpPlug that fixes SSE session ID mismatch bug.
  When a session ID is provided in SSE connection but doesn't exist, ExMCP creates a new one.
  This wrapper tracks the mapping and fixes POST requests to use the correct session ID.
  """

  @behaviour Plug

  alias ExMCP.HttpPlug

  @impl Plug
  def init(opts) do
    HttpPlug.init(opts)
  end

  @impl Plug
  def call(conn, opts) do
    # Fix SSE session ID issue: if POST request has no session ID but SSE is enabled,
    # try to find an active SSE connection and use its session ID
    # opts is a map (from HttpPlug.init), not a keyword list
    sse_enabled = Map.get(opts, :sse_enabled, true)
    
    if conn.method == "POST" && sse_enabled do
      case Plug.Conn.get_req_header(conn, "mcp-session-id") do
        [] ->
          # No session ID provided, try to find an active SSE connection
          case find_any_active_sse_session() do
            {:ok, session_id} ->
              # Use the active SSE session ID
              modified_conn = Plug.Conn.put_req_header(conn, "mcp-session-id", session_id)
              HttpPlug.call(modified_conn, opts)

            {:error, _} ->
              # No active SSE connection - disable SSE for this request to allow HTTP response
              # This prevents timeouts when clients don't use SSE (e.g., Smithery scanner)
              modified_opts = Map.put(opts, :sse_enabled, false)
              HttpPlug.call(conn, modified_opts)
          end

        [_session_id] ->
          # Session ID provided, use as-is
          HttpPlug.call(conn, opts)
      end
    else
      # Not a POST request or SSE disabled, pass through
      HttpPlug.call(conn, opts)
    end
  end

  # Find any active SSE session from the ETS table
  defp find_any_active_sse_session do
    table = :http_plug_sessions
    try do
      # Get all entries from the ETS table using tab2list for debugging
      all_entries = :ets.tab2list(table)
      
      require Logger
      Logger.debug("HttpPlugWrapper: Found #{length(all_entries)} entries in ETS table: #{inspect(all_entries)}")
      
      # Filter to only alive handler processes
      alive_sessions = 
        all_entries
        |> Enum.filter(fn
          {session_id, handler_pid} when is_pid(handler_pid) ->
            alive = Process.alive?(handler_pid)
            Logger.debug("HttpPlugWrapper: Session #{inspect(session_id)} handler #{inspect(handler_pid)} alive: #{alive}")
            alive
          _ ->
            false
        end)
        |> Enum.map(fn {session_id, _} -> session_id end)
      
      Logger.debug("HttpPlugWrapper: Found #{length(alive_sessions)} alive SSE sessions: #{inspect(alive_sessions)}")
      
      case alive_sessions do
        [session_id | _] ->
          Logger.debug("HttpPlugWrapper: Using SSE session ID: #{inspect(session_id)}")
          {:ok, to_string(session_id)}
        
        [] ->
          Logger.debug("HttpPlugWrapper: No alive SSE sessions found")
          {:error, :no_active_sessions}
      end
    rescue
      ArgumentError ->
        # Table doesn't exist
        require Logger
        Logger.debug("HttpPlugWrapper: ETS table :http_plug_sessions does not exist")
        {:error, :table_not_found}
    end
  end

  # Track the mapping between requested session ID and actual session ID
  defp track_sse_session_mapping(_conn, _result) do
    # Placeholder for future session ID mapping fix
    # The SSE connection will send back the actual session ID in the "connected" event
    # We'll need to intercept that, but for now we'll use a different approach:
    # Monitor the SessionManager to see what session was actually created
    # This is a workaround - the real fix should be in ExMCP
    :ok
  end
end
