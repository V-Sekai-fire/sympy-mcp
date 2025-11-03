# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

import Config

# Configure logger to output to stderr instead of stdout for MCP stdio communication
# This ensures JSON-RPC responses go to stdout and logs go to stderr
if System.get_env("MCP_STDIO_MODE") == "true" do
  config :logger, :console,
    format: "$time $metadata[$level] $message\n",
    metadata: [:request_id],
    device: :standard_error
end

