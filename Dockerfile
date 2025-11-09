# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

# Build stage
FROM almalinux:10 AS builder

WORKDIR /app

# Install build dependencies
RUN dnf update -y && dnf install -y \
    gcc g++ make git \
    python3 python3-devel python3-pip \
    openssl-devel \
    zlib-devel \
    unzip \
    wget \
    curl \
    which \
    ca-certificates \
    ncurses-devel

# Install Erlang/OTP 28
RUN dnf install -y epel-release && \
    dnf install -y erlang erlang-erl_interface

# Install Elixir 1.19 from precompiled binaries
RUN cd /tmp && \
    curl -L https://github.com/elixir-lang/elixir/releases/download/v1.19.4/elixir-otp-28.zip -o elixir.zip && \
    unzip elixir.zip && \
    mkdir -p /opt/elixir && \
    mv bin lib man /opt/elixir/ && \
    rm elixir.zip

ENV PATH="/opt/elixir/bin:${PATH}"

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy dependency files
COPY mix.exs mix.lock ./
COPY config ./config

# Install dependencies
RUN mix deps.get --only prod && \
    mix deps.compile

# Copy source code
COPY lib ./lib

# Compile the application
RUN mix compile

# Build the release
RUN MIX_ENV=prod mix release

# Runtime stage
FROM almalinux:10

WORKDIR /app

# Install runtime dependencies including Python for SymPy
RUN dnf update -y && dnf install -y \
    openssl \
    ncurses-libs \
    libstdc++ \
    erlang \
    wget \
    curl \
    unzip \
    python3 \
    python3-pip \
    ca-certificates && \
    dnf clean all

# Install Elixir 1.19 from precompiled binaries
RUN cd /tmp && \
    curl -L https://github.com/elixir-lang/elixir/releases/download/v1.19.4/elixir-otp-28.zip -o elixir.zip && \
    unzip elixir.zip && \
    mkdir -p /opt/elixir && \
    mv bin lib man /opt/elixir/ && \
    rm elixir.zip

ENV PATH="/opt/elixir/bin:${PATH}"

# Install SymPy (pythonx will use this)
RUN pip3 install --no-cache-dir sympy mpmath

# Copy the release from builder
COPY --from=builder /app/_build/prod/rel/sympy_mcp ./sympy_mcp

# Set environment variables
ENV MIX_ENV=prod
ENV MCP_TRANSPORT=http
ENV PORT=8081

# Expose the port
EXPOSE 8081

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT}/mcp || exit 1

# Start the server
CMD ["./sympy_mcp/bin/sympy_mcp", "start"]

