# Development Guide

This document provides information for developers working on SymPy MCP.

## Development Setup

```bash
mix test          # Run tests
mix dialyzer      # Static analysis
mix release       # Build release
```

## Architecture

### Key Components

- `SympyMcp.Application` - Main supervisor with transport selection
- `SympyMcp.NativeService` - MCP server implementation (ExMCP)
- `SympyMcp.SympyTools` - Core SymPy functionality via Pythonx
- `SympyMcp.StdioServer` / `SympyMcp.HttpServer` - Transport implementations
- `SympyMcp.Router` - HTTP router with health check endpoint
- `SympyMcp.HttpPlugWrapper` - SSE session ID fix wrapper

### Transport Selection

The application automatically selects the transport based on environment variables:

1. If `MCP_TRANSPORT` is set to `"http"` or `"stdio"`, that transport is used
2. If `PORT` environment variable is set, HTTP transport is used (for containerized deployments)
3. Otherwise, STDIO transport is used (default for local development)

## Dependencies

- [ex_mcp](https://github.com/fire/ex_mcp) - MCP protocol implementation
- [pythonx](https://hex.pm/packages/pythonx) - Python interop for Elixir
- [jason](https://hex.pm/packages/jason) - JSON encoding/decoding

## Code Quality

The project uses:

- **Dialyzer** for static type analysis
- **Credo** for code style checking
- **ExUnit** for testing with 70% coverage threshold

Run quality checks:

```bash
mix dialyzer
mix credo
mix test --cover
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes and add tests
4. Ensure all tests pass (`mix test`)
5. Run code quality checks (`mix dialyzer && mix credo`)
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Submit a pull request

### Code Style

- Follow Elixir style guide
- Use `mix format` before committing
- Add `@moduledoc` and `@doc` for public functions
- Keep functions focused and small

## Testing

Tests are located in the `test/` directory. The test suite includes:

- Unit tests for SymPy tools
- Integration tests for MCP server
- Mock fallback tests for when Pythonx is unavailable

Run tests with:

```bash
mix test
```

## Building Releases

To build a production release:

```bash
MIX_ENV=prod mix release
```

The release will be available at `_build/prod/rel/sympy_mcp/`.

## Debugging

Enable debug logging:

```bash
MIX_ENV=dev mix mcp.server
```

Or for HTTP mode:

```bash
MIX_ENV=dev PORT=8081 mix mcp.server
```

## Author

K. S. Ernest (iFire) Lee
