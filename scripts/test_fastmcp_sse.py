#!/usr/bin/env python3
"""
Test SymPy MCP server using fastmcp client with SSE transport.
"""

import asyncio
import sys
import os

try:
    from fastmcp import Client
except ImportError:
    print("Error: fastmcp not installed. Install with: pip3 install fastmcp")
    sys.exit(1)

async def test_sse():
    """Test SSE transport"""
    print("=" * 60)
    print("Testing SymPy MCP Server - SSE Transport")
    print("=" * 60)
    
    sse_url = "http://localhost:8081/sse"
    
    print(f"\nConnecting to SSE endpoint: {sse_url}\n")
    
    try:
        async with Client(sse_url) as client:
            # Initialize
            print("1. Initializing connection...")
            init_result = await client.initialize()
            print(f"   Server: {init_result.server_info.name} v{init_result.server_info.version}")
            print(f"   Protocol: {init_result.protocol_version}\n")
            
            # List tools
            print("2. Listing available tools...")
            tools = await client.list_tools()
            print(f"   Found {len(tools.tools)} tools:")
            for tool in tools.tools:
                print(f"     - {tool.name}: {tool.description}")
            print()
            
            # Test sympy_solve
            print("3. Testing sympy_solve (x² - 4 = 0)...")
            result = await client.call_tool("sympy_solve", {
                "equation": "x**2 - 4",
                "variable": "x"
            })
            print(f"   Result: {result.content[0].text if result.content else 'No result'}\n")
            
            # Test sympy_simplify
            print("4. Testing sympy_simplify (x² + 2x + 1)...")
            result = await client.call_tool("sympy_simplify", {
                "expression": "x**2 + 2*x + 1"
            })
            print(f"   Result: {result.content[0].text if result.content else 'No result'}\n")
            
            # Test sympy_differentiate
            print("5. Testing sympy_differentiate (x²)...")
            result = await client.call_tool("sympy_differentiate", {
                "expression": "x**2",
                "variable": "x"
            })
            print(f"   Result: {result.content[0].text if result.content else 'No result'}\n")
            
            # Test sympy_integrate
            print("6. Testing sympy_integrate (x)...")
            result = await client.call_tool("sympy_integrate", {
                "expression": "x",
                "variable": "x"
            })
            print(f"   Result: {result.content[0].text if result.content else 'No result'}\n")
            
            # Test sympy_expand
            print("7. Testing sympy_expand ((x+1)**2)...")
            result = await client.call_tool("sympy_expand", {
                "expression": "(x+1)**2"
            })
            print(f"   Result: {result.content[0].text if result.content else 'No result'}\n")
            
            # Test sympy_factor
            print("8. Testing sympy_factor (x² + 2x + 1)...")
            result = await client.call_tool("sympy_factor", {
                "expression": "x**2 + 2*x + 1"
            })
            print(f"   Result: {result.content[0].text if result.content else 'No result'}\n")
            
            print("=" * 60)
            print("SSE Transport Test Complete!")
            print("=" * 60)
            
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(test_sse())

