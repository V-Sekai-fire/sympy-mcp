#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee
#
# Script to restart the MCP server release.
# This script stops the running release (if any) and starts it again.
#
# Note: For MCP servers, foreground mode is typically used for stdio communication.
# This script can be used for manual testing or if running as a service.

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Path to the release binary
RELEASE_BIN="$PROJECT_ROOT/_build/prod/rel/sympy_mcp/bin/sympy_mcp"
RELEASE_NAME="sympy_mcp"

# Check if release exists, if not build it first
if [ ! -f "$RELEASE_BIN" ]; then
  echo "Release not found. Building release..."
  cd "$PROJECT_ROOT"
  MIX_ENV=prod mix release
fi

# Function to check if release is running (as daemon)
is_running() {
  "$RELEASE_BIN" ping > /dev/null 2>&1
}

# Function to stop the release (if running as daemon)
stop_release() {
  if is_running; then
    echo "Stopping $RELEASE_NAME daemon..."
    "$RELEASE_BIN" stop
    # Wait for the release to fully stop
    sleep 2
    echo "$RELEASE_NAME stopped."
  else
    echo "$RELEASE_NAME is not running as a daemon."
  fi
}

# Function to start the release
start_release() {
  echo "Starting $RELEASE_NAME for stdio communication..."
  echo "Press Ctrl+C to stop the server."
  echo ""
  # Use start command for stdio communication
  # (daemon mode detaches from terminal, so we use start for stdio)
  RELEASE_ROOT="$PROJECT_ROOT/_build/prod/rel/sympy_mcp"
  export MCP_STDIO_MODE=true
  exec "$RELEASE_ROOT/bin/sympy_mcp" start
}

# Main restart logic
main() {
  # For foreground mode, we don't need to check if it's running
  # since foreground mode is for stdio communication
  stop_release
  start_release
}

main

