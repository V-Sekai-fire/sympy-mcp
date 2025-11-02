[
  # Ignore Pythonx related warnings since it's a NIF
  {:unknown_function, "lib/sympy_mcp/sympy_tools.ex", :_},
  {:unknown_type, "lib/sympy_mcp/sympy_tools.ex", :_},

  # Ignore warnings from ex_mcp DSL generated code
  {:no_match, "lib/sympy_mcp/native_service.ex", :_},
  {:no_return, "lib/sympy_mcp/native_service.ex", :_},

  # Ignore Jason encoding warnings
  {:unknown_function, "lib/sympy_mcp/*.ex", :_},
  {:unknown_type, "lib/sympy_mcp/*.ex", :_}
]
