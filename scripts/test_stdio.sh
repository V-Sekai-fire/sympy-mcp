#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee
#
# Test script for MCP server stdio communication.
# Sends JSON-RPC requests and verifies responses.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RELEASE_BIN="$PROJECT_ROOT/_build/prod/rel/sympy_mcp/bin/sympy_mcp"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if release exists
if [ ! -f "$RELEASE_BIN" ]; then
  echo -e "${RED}Error: Release not found. Please build it first with:${NC}"
  echo "  MIX_ENV=prod mix release"
  exit 1
fi

echo -e "${YELLOW}Testing MCP server stdio communication...${NC}"
echo ""

# Function to send JSON-RPC request and get response
send_request() {
  local request="$1"
  echo "$request" | "$RELEASE_BIN" foreground 2>&1 | head -1
}

# Test 1: Initialize request
echo -e "${YELLOW}Test 1: Initialize request${NC}"
INIT_REQUEST='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test-client","version":"1.0.0"}}}'
echo "Sending: $INIT_REQUEST"
RESPONSE=$(echo "$INIT_REQUEST" | timeout 5 "$RELEASE_BIN" foreground 2>&1 | head -1 || true)
if [ -n "$RESPONSE" ]; then
  echo -e "${GREEN}Response received:${NC} $RESPONSE"
else
  echo -e "${RED}No response received${NC}"
fi
echo ""

# Test 2: List tools request (after initialize)
echo -e "${YELLOW}Test 2: Tools list request${NC}"
TOOLS_REQUEST='{"jsonrpc":"2.0","id":2,"method":"tools/list"}'
echo "Sending: $TOOLS_REQUEST"
RESPONSE=$(echo "$TOOLS_REQUEST" | timeout 5 "$RELEASE_BIN" foreground 2>&1 | head -1 || true)
if [ -n "$RESPONSE" ]; then
  echo -e "${GREEN}Response received:${NC} $RESPONSE"
else
  echo -e "${RED}No response received${NC}"
fi
echo ""

echo -e "${GREEN}Test completed!${NC}"
echo ""
echo "Note: Full stdio testing requires interactive communication."
echo "For production use, the release should be started with:"
echo "  $RELEASE_BIN foreground"

