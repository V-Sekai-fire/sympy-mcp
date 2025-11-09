# SymPy MCP

[![smithery badge](https://smithery.ai/badge/@V-Sekai-fire/sympy-mcp)](https://smithery.ai/server/@V-Sekai-fire/sympy-mcp)

An Elixir-based MCP (Model Context Protocol) server that provides symbolic mathematics capabilities using SymPy.

## Features

- **Symbolic Equation Solving**: Solve algebraic equations for variables
- **Expression Simplification**: Simplify complex symbolic expressions
- **Differentiation & Integration**: Compute derivatives and integrals
- **Expression Manipulation**: Expand and factor algebraic expressions
- **Numerical Evaluation**: Evaluate expressions with variable substitutions

## Quick Start

### Prerequisites

- Elixir 1.18+
- OpenSSL development libraries

> **Note**: Python 3.12 and SymPy are automatically installed during compilation.

### Installation

```bash
git clone https://github.com/V-Sekai-fire/sympy-mcp.git
cd sympy-mcp
mix deps.get
mix compile
```

## Usage

### STDIO Transport (Default)

For local development:

```bash
mix mcp.server
```

Or using release:

```bash
./_build/prod/rel/sympy_mcp/bin/sympy_mcp start
```

### HTTP Transport

For web deployments (e.g., Smithery):

```bash
PORT=8081 MIX_ENV=prod ./_build/prod/rel/sympy_mcp/bin/sympy_mcp start
```

**Endpoints:**

- `POST /` - JSON-RPC 2.0 MCP requests
- `GET /sse` - Server-Sent Events for streaming
- `GET /health` - Health check

### Docker

```bash
docker build -t sympy-mcp .
docker run -d -p 8081:8081 --name sympy-mcp sympy-mcp
```

### Available Tools

- `sympy_solve` - Solve equations (e.g., `x**2 - 1` for `x`)
- `sympy_simplify` - Simplify expressions
- `sympy_differentiate` - Compute derivatives
- `sympy_integrate` - Compute integrals
- `sympy_expand` - Expand expressions
- `sympy_factor` - Factor expressions
- `sympy_evaluate` - Evaluate numerically

### Example

**STDIO:**

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

**HTTP:**

```bash
curl -X POST http://localhost:8081/ \
  -H "Content-Type: application/json" \
  -H "mcp-protocol-version: 2025-06-18" \
  -d '{"jsonrpc": "2.0", "id": 1, "method": "tools/call", "params": {"name": "sympy_solve", "arguments": {"equation": "x**2 - 4", "variable": "x"}}}'
```

## Configuration

**Environment Variables:**

- `MCP_TRANSPORT` - Transport type (`"http"` or `"stdio"`)
- `PORT` - HTTP server port (default: 8081)
- `HOST` - HTTP server host (default: `0.0.0.0` if PORT set, else `localhost`)
- `MIX_ENV` - Environment (`prod`, `dev`, `test`)
- `ELIXIR_ERL_OPTIONS` - Erlang options (set to `"+fnu"` for UTF-8)

**Transport Selection:**

1. If `MCP_TRANSPORT` is set, use that transport
2. If `PORT` is set, use HTTP transport
3. Otherwise, use STDIO transport (default)

## Troubleshooting

**Python/SymPy not found**: The build process installs Python 3.12 automatically. Run `mix clean && mix compile` if issues persist.

**Port already in use**: Change `PORT` environment variable or stop conflicting services.

**Compilation errors**: Run `mix deps.get && mix clean && mix compile`.

**Debug mode**: Use `MIX_ENV=dev mix mcp.server` for verbose logging.

## License

MIT License - see LICENSE.md for details.

## Contributing

See [DEVELOPING.md](DEVELOPING.md) for development setup and contribution guidelines.
