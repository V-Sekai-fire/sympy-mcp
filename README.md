# SymPy MCP

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

- Elixir 1.19 or later
- Python 3.x with SymPy installed
- OpenSSL development libraries

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

The application runs as an MCP server that communicates via stdio:

```bash
mix mcp.server
```

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

- `SympyMcp.Application`: Main application supervisor
- `SympyMcp.NativeService`: MCP server implementation using ExMCP
- `SympyMcp.StdioServer`: Stdio-based MCP transport
- `SympyMcp.SympyTools`: Core SymPy functionality via Pythonx
- `SympyMcp.ToolHandlers`: MCP tool request handlers

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
