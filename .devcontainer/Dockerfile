FROM almalinux:9

WORKDIR /workspace

# Install system dependencies
RUN dnf update -y && dnf install -y \
    gcc g++ make git \
    python3 python3-devel python3-pip \
    openssl-devel \
    zlib-devel \
    unzip \
    wget \
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

# Install SymPy and other Python dependencies
RUN pip3 install sympy mpmath

# Create development user
RUN useradd -m -s /bin/bash -G wheel dev && \
    echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER dev

ENV PATH="/home/dev/.local/bin:${PATH}"
