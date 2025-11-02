# SPDX-License-Identifier: MIT
# Copyright (c) 2025-present K. S. Ernest (iFire) Lee

import Config

# Configure Pythonx to install SymPy
config :pythonx, :uv_init,
  pyproject_toml: """
  [project]
  name = "mcp_aria_sympy"
  version = "0.1.0"
  requires-python = "==3.12.*"
  dependencies = [
    "sympy>=1.12.0"
  ]
  """
