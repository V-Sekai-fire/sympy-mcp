# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

defmodule SympyMcp.StdioServer do
  @moduledoc """
  Stdio-based MCP server that reads JSON-RPC messages from stdin and writes responses to stdout.
  """

  require Logger

  @spec child_spec(term()) :: Supervisor.child_spec()
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  @spec start_link(term()) :: {:ok, pid()}
  def start_link(_opts) do
    {:ok, spawn_link(__MODULE__, :run, [])}
  end

  @spec run() :: no_return()
  def run do
    Logger.info("MCP Stdio Server started, listening on stdin")
    read_messages()
  end

  defp read_messages do
    case IO.read(:stdio, :line) do
      :eof ->
        Logger.info("EOF received, exiting")
        :ok

      {:error, reason} ->
        Logger.error("Error reading from stdin: #{inspect(reason)}")
        :error

      line ->
        process_line(String.trim(line))
    end
  end

  defp process_line(""), do: read_messages()

  defp process_line(message) do
    case process_message(message) do
      :ok -> read_messages()
    end
  end

  defp process_message(message) do
    case Jason.decode(message) do
      {:ok, request} ->
        Logger.debug("Received request: #{inspect(request)}")

        case validate_request(request) do
          :ok ->
            process_valid_request(request)

          {:error, validation_error} ->
            Logger.error("Request validation error: #{inspect(validation_error)}")
            send_error_response(-32_600, "Invalid Request: #{validation_error}", Map.get(request, "id", nil))
            :ok
        end

      {:error, reason} ->
        Logger.error("JSON decode error: #{inspect(reason)}")
        send_error_response(-32_700, "Parse error: Invalid JSON", nil)
        :ok
    end
  rescue
    e ->
      Logger.error("Unexpected error processing message: #{Exception.message(e)}")
      send_error_response(-32_603, "Internal error", nil)
      :ok
  end

  defp validate_request(request) when is_map(request) do
    cond do
      not Map.has_key?(request, "jsonrpc") ->
        {:error, "Missing jsonrpc field"}

      Map.get(request, "jsonrpc") != "2.0" ->
        {:error, "Unsupported JSON-RPC version"}

      not Map.has_key?(request, "method") ->
        {:error, "Missing method field"}

      not is_binary(Map.get(request, "method")) ->
        {:error, "Method must be a string"}

      true ->
        :ok
    end
  end

  defp validate_request(_), do: {:error, "Request must be a JSON object"}

  defp process_valid_request(request) do
    case GenServer.call(SympyMcp.NativeService, {:process_request, request}, 5000) do
      {:ok, response} ->
        Logger.debug("Sending response: #{inspect(response)}")
        IO.write(Jason.encode!(response) <> "\n")
        :ok

      {:error, reason} ->
        Logger.error("Request processing error: #{inspect(reason)}")
        send_error_response(-32_603, "Internal error: #{inspect(reason)}", Map.get(request, "id"))
        :ok
    end
  end

  defp send_error_response(code, message, id) do
    error_response = %{
      "jsonrpc" => "2.0",
      "error" => %{
        "code" => code,
        "message" => message
      },
      "id" => id
    }

    IO.write(Jason.encode!(error_response) <> "\n")
  end
end
