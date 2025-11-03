#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee
#
# Script to start the MCP server using the Mix release.
# This script runs the release in foreground mode for stdio communication.

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Path to the release binary
RELEASE_BIN="$PROJECT_ROOT/_build/prod/rel/sympy_mcp/bin/sympy_mcp"

# Check if release exists, if not build it
if [ ! -f "$RELEASE_BIN" ]; then
  echo "Release not found. Building release..."
  cd "$PROJECT_ROOT"
  MIX_ENV=prod mix release
fi

# Run the release using start command which keeps it running with stdio
# Set MCP_STDIO_MODE to configure logger for stdio communication
# This ensures JSON-RPC goes to stdout and logs go to stderr
RELEASE_ROOT="$PROJECT_ROOT/_build/prod/rel/sympy_mcp"
export MCP_STDIO_MODE=true
exec "$RELEASE_ROOT/bin/sympy_mcp" start

