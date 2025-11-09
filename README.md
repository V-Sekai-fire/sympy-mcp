# SymPy MCP

[![smithery badge](https://smithery.ai/badge/@V-Sekai-fire/sympy-mcp)](https://smithery.ai/server/@V-Sekai-fire/sympy-mcp)

An Elixir-based MCP (Model Context Protocol) server that provides symbolic mathematics capabilities using SymPy.

## Overview

This project implements an MCP server that exposes SymPy's symbolic mathematics functionality through a standardized protocol. It allows MCP clients to perform symbolic computations like equation solving, differentiation, integration, simplification, and more.

## Features

- **Symbolic Equation Solving**: Solve algebraic equations for variables
- **Expression Simplification**: Simplify complex symbolic expressions
- **Differentiation**: Compute derivatives of expressions
- **Integration**: Compute integrals of expressions
- **Expression Expansion**: Expand algebraic expressions
- **Expression Factoring**: Factor algebraic expressions
- **Numerical Evaluation**: Evaluate expressions with variable substitutions

## Installation

### Prerequisites

- Elixir 1.18 or later
- OpenSSL development libraries

**Note**: Python 3.12 and SymPy are automatically installed during the compilation process.

### Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/V-Sekai-fire/sympy-mcp.git
   cd sympy-mcp
   ```

2. Install dependencies:

   ```bash
   mix deps.get
   ```

3. Compile the project (this will automatically install Python and SymPy):

   ```bash
   mix compile
   ```

   The compilation process will:
   - Download Python 3.12 via uv package manager
   - Create a virtual environment
   - Install SymPy and its dependencies

## Usage

### As an MCP Server

The application supports both STDIO and HTTP transports. The transport is automatically selected based on environment variables:

#### STDIO Transport (Default)

For local development and CLI usage:

```bash
mix mcp.server
```

Or using the release:

```bash
./_build/prod/rel/sympy_mcp/bin/sympy_mcp start
```

#### HTTP Transport

For web-based deployments (e.g., Smithery):

```bash
PORT=8081 MIX_ENV=prod ./_build/prod/rel/sympy_mcp/bin/sympy_mcp start
```

Or explicitly set the transport:

```bash
MCP_TRANSPORT=http PORT=8081 MIX_ENV=prod ./_build/prod/rel/sympy_mcp/bin/sympy_mcp start
```

The HTTP server provides:

- **MCP Endpoint**: `POST /` - JSON-RPC 2.0 MCP requests
- **SSE Endpoint**: `GET /sse` - Server-Sent Events for real-time communication
- **Health Check**: `GET /health` - Health check endpoint for monitoring

### Docker Deployment

Build the Docker image:

```bash
docker build -t sympy-mcp .
```

Run the container:

```bash
docker run -d -p 8081:8081 --name sympy-mcp sympy-mcp
```

The container automatically uses HTTP transport when the `PORT` environment variable is set.

### Smithery Deployment

This project is configured for deployment on [Smithery](https://smithery.ai):

1. Push your code to GitHub
2. Connect your repository to Smithery
3. Deploy using the `smithery.yaml` configuration

The deployment includes:

- Multi-stage Docker build for optimized image size
- Health check endpoint at `/health`
- HTTP MCP endpoint with CORS support
- Automatic transport selection based on environment

### Available Tools

The server provides the following MCP tools:

- `sympy_solve`: Solves equations (e.g., `x**2 - 1` for `x`)
- `sympy_simplify`: Simplifies expressions
- `sympy_differentiate`: Computes derivatives
- `sympy_integrate`: Computes integrals
- `sympy_expand`: Expands expressions
- `sympy_factor`: Factors expressions
- `sympy_evaluate`: Evaluates expressions numerically

### Example Usage

#### STDIO Transport

The server expects JSON-RPC 2.0 messages on stdin and responds on stdout. Example request:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "sympy_solve",
    "arguments": {
      "equation": "x**2 - 4",
      "variable": "x"
    }
  }
}
```

#### HTTP Transport Example

Send POST requests to the HTTP endpoint:

```bash
curl -X POST http://localhost:8081/ \
  -H "Content-Type: application/json" \
  -H "mcp-protocol-version: 2025-06-18" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
      "name": "sympy_solve",
      "arguments": {
        "equation": "x**2 - 4",
        "variable": "x"
      }
    }
  }'
```

For streaming responses, connect to the SSE endpoint:

```bash
curl -N -H "Accept: text/event-stream" \
  -H "mcp-protocol-version: 2025-06-18" \
  http://localhost:8081/sse
```

Then send POST requests as above. Responses will be delivered via Server-Sent Events.

## Development

### Running Tests

```bash
mix test
```

### Code Quality

Run static analysis:

```bash
mix dialyzer
```

### Building Release

```bash
mix release
```

## Architecture

The application consists of several key components:

- `SympyMcp.Application`: Main application supervisor with automatic transport selection
- `SympyMcp.NativeService`: MCP server implementation using ExMCP
- `SympyMcp.StdioServer`: Stdio-based MCP transport
- `SympyMcp.HttpServer`: HTTP-based MCP transport with SSE support
- `SympyMcp.Router`: HTTP router with health check endpoint
- `SympyMcp.SympyTools`: Core SymPy functionality via Pythonx
- `SympyMcp.ToolHandlers`: MCP tool request handlers

### Transport Selection

The application automatically selects the transport based on environment variables:

1. If `MCP_TRANSPORT` is set to `"http"` or `"stdio"`, that transport is used
2. If `PORT` environment variable is set, HTTP transport is used (for containerized deployments)
3. Otherwise, STDIO transport is used (default for local development)

### Environment Variables

- `MCP_TRANSPORT`: Transport type (`"http"` or `"stdio"`)
- `PORT`: HTTP server port (default: 8081)
- `MIX_ENV`: Environment (`prod`, `dev`, `test`)
- `ELIXIR_ERL_OPTIONS`: Erlang options (set to `"+fnu"` for UTF-8 support)

## Dependencies

- [ex_mcp](https://github.com/azmaveth/ex_mcp.git): MCP protocol implementation
- [pythonx](https://hex.pm/packages/pythonx): Python interop for Elixir
- [jason](https://hex.pm/packages/jason): JSON encoding/decoding

## License

MIT License - see LICENSE.md file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## Authors

- K. S. Ernest (iFire) Lee

## Performance

The SymPy MCP server is optimized for symbolic mathematics operations:

- **Python Integration**: Uses Pythonx for efficient Python interop without subprocess overhead
- **Connection Pooling**: HTTP transport supports concurrent requests via Cowboy
- **Lazy Evaluation**: SymPy operations are evaluated on-demand
- **Memory Efficient**: Minimal memory footprint for symbolic computations

### Benchmarks

For typical symbolic operations (solve, differentiate, integrate):

- **Response Time**: < 100ms for simple expressions
- **Memory Usage**: ~50MB base + ~10MB per concurrent operation
- **Concurrent Requests**: Supports 100+ simultaneous operations

## Troubleshooting

### Common Issues

**Python/SymPy not found**: Ensure Python 3.12+ is available. The build process will install it automatically.

**Port already in use**: Change the `PORT` environment variable or stop other services using port 8081.

**Compilation errors**: Run `mix deps.get` and `mix clean` then `mix compile`.

**Test failures**: Ensure all dependencies are properly installed with `mix deps.get`.

### Debug Mode

Enable debug logging:

```bash
MIX_ENV=dev mix mcp.server
```

Or for HTTP mode:

```bash
MIX_ENV=dev PORT=8081 mix mcp.server
```
