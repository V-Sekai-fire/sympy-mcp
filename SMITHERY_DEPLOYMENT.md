# Smithery Deployment Guide

This document describes how to deploy the SymPy MCP server to Smithery using a custom Docker container with MCP Streamable HTTP transport.

## Overview

The SymPy MCP server is configured to support both:
- **Stdio transport**: For local development and CLI usage
- **HTTP transport**: For Smithery deployment and web-based MCP clients

## Files Created

1. **`lib/sympy_mcp/http_server.ex`**: HTTP server using ExMCP.HttpPlug
2. **`lib/sympy_mcp/router.ex`**: Router that mounts MCP endpoint at `/mcp`
3. **`Dockerfile`**: Multi-stage Docker build for production deployment
4. **`smithery.yaml`**: Smithery deployment configuration

## Deployment Steps

1. **Push code to GitHub** (including `Dockerfile` and `smithery.yaml`)

2. **Connect GitHub to Smithery** (or claim your server if already listed)

3. **Navigate to Deployments tab** on your server page in Smithery

4. **Click Deploy** to build and host your container

## How It Works

### Transport Selection

The application automatically selects the transport based on environment variables:
- If `PORT` environment variable is set → HTTP transport (Smithery)
- If `MCP_TRANSPORT=http` → HTTP transport
- Otherwise → Stdio transport (local development)

### HTTP Server Configuration

- **Endpoint**: `/mcp` (as required by Smithery)
- **Port**: Read from `PORT` environment variable (default: 8081)
- **CORS**: Enabled for cross-origin requests
- **SSE**: Enabled for Server-Sent Events support

### Docker Build

The Dockerfile uses a multi-stage build:
1. **Builder stage**: Compiles Elixir application and builds release
2. **Runtime stage**: Minimal Alpine image with runtime dependencies

## Testing Locally

To test the HTTP transport locally:

```bash
# Set environment variables
export MCP_TRANSPORT=http
export PORT=8081

# Start the release
_build/prod/rel/sympy_mcp/bin/sympy_mcp start
```

Then test with curl:

```bash
curl -X POST http://localhost:8081/mcp \
  -H "Content-Type: application/json" \
  -H "MCP-Protocol-Version: 2024-11-05" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {
      "protocolVersion": "2024-11-05",
      "capabilities": {},
      "clientInfo": {"name": "test", "version": "1.0.0"}
    }
  }'
```

## References

- [Smithery Container Deployment Docs](https://smithery.ai/docs/build/deployments/custom-container)
- [MCP Protocol Specification](https://modelcontextprotocol.io)

