#!/bin/bash
# Simple test of SymPy MCP server - connect via SSE and send requests

set -e

BASE_URL="http://localhost:8081"
SSE_URL="${BASE_URL}/sse"

echo "=== Testing SymPy MCP Server ==="
echo ""

# Connect to SSE and get session ID in background
echo "1. Connecting to SSE endpoint..."
(
  curl -s -N -H "Accept: text/event-stream" \
    -H "mcp-protocol-version: 2025-06-18" \
    "${SSE_URL}" 2>/dev/null | while IFS= read -r line; do
    if [[ "$line" =~ ^data:.*session_id ]]; then
      echo "$line" | sed 's/data: //' | jq -r '.session_id' > /tmp/sse_session_id
      echo "   Got session ID from SSE"
      break
    fi
  done
) &
SSE_PID=$!

sleep 2
SESSION_ID=$(cat /tmp/sse_session_id 2>/dev/null || echo "")
rm -f /tmp/sse_session_id

if [ -z "$SESSION_ID" ]; then
  echo "   Warning: No session ID, but continuing..."
fi

echo ""
echo "2. Testing sympy_solve (x**2 - 4 = 0)..."
curl -s -X POST "${BASE_URL}/" \
  -H "Content-Type: application/json" \
  -H "mcp-protocol-version: 2025-06-18" \
  ${SESSION_ID:+-H "mcp-session-id: $SESSION_ID"} \
  -d '{
    "jsonrpc": "2.0",
    "id": 3,
    "method": "tools/call",
    "params": {
      "name": "sympy_solve",
      "arguments": {
        "equation": "x**2 - 4",
        "variable": "x"
      }
    }
  }'
echo ""
echo "   (Check SSE stream above for response)"
echo ""

sleep 2

echo "3. Testing sympy_simplify (x**2 + 2*x + 1)..."
curl -s -X POST "${BASE_URL}/" \
  -H "Content-Type: application/json" \
  -H "mcp-protocol-version: 2025-06-18" \
  ${SESSION_ID:+-H "mcp-session-id: $SESSION_ID"} \
  -d '{
    "jsonrpc": "2.0",
    "id": 4,
    "method": "tools/call",
    "params": {
      "name": "sympy_simplify",
      "arguments": {
        "expression": "x**2 + 2*x + 1"
      }
    }
  }'
echo ""
echo "   (Check SSE stream above for response)"
echo ""

# Keep SSE connection alive a bit longer to see responses
sleep 3

kill $SSE_PID 2>/dev/null || true

echo "=== Test Complete ==="
echo "Note: Responses are delivered via SSE events. Check the SSE stream output above."

