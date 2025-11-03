#!/usr/bin/env python3
"""
Test script for MCP server stdio communication.
Sends JSON-RPC requests and verifies responses.
"""
import json
import subprocess
import sys
import os
import time

# Get project root directory
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
RELEASE_BIN = os.path.join(PROJECT_ROOT, "_build/prod/rel/sympy_mcp/bin/sympy_mcp")

def test_stdio():
    """Test stdio communication with MCP server"""
    
    # Check if release exists
    if not os.path.exists(RELEASE_BIN):
        print(f"Error: Release not found at {RELEASE_BIN}")
        print("Please build it first with: MIX_ENV=prod mix release")
        sys.exit(1)
    
    print("Starting MCP server release...")
    print(f"Binary: {RELEASE_BIN}")
    print("")
    
    # Start the release process using start command
    RELEASE_ROOT = os.path.join(PROJECT_ROOT, "_build/prod/rel/sympy_mcp")
    release_bin = os.path.join(RELEASE_ROOT, "bin/sympy_mcp")
    
    # Set environment variable for stdio mode
    env = os.environ.copy()
    env["MCP_STDIO_MODE"] = "true"
    
    process = subprocess.Popen(
        [release_bin, "start"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        bufsize=1,
        env=env
    )
    
    # Check if process started successfully
    if process.poll() is not None:
        stderr_output = process.stderr.read()
        print(f"✗ Process exited immediately with code {process.returncode}")
        if stderr_output:
            print(f"Error output: {stderr_output}")
        sys.exit(1)
    
    try:
        # Wait a moment for server to start
        time.sleep(2)
        
        # Check process is still running
        if process.poll() is not None:
            stderr_output = process.stderr.read()
            print(f"✗ Process exited during startup with code {process.returncode}")
            if stderr_output:
                print(f"Error output: {stderr_output}")
            sys.exit(1)
        
        # Test 1: Initialize request
        print("Test 1: Initialize request")
        init_request = {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "initialize",
            "params": {
                "protocolVersion": "2024-11-05",
                "capabilities": {},
                "clientInfo": {
                    "name": "test-client",
                    "version": "1.0.0"
                }
            }
        }
        
        request_str = json.dumps(init_request) + "\n"
        print(f"Sending: {request_str.strip()}")
        process.stdin.write(request_str)
        process.stdin.flush()
        
        # Read response (filter out log lines)
        try:
            max_attempts = 10
            response_line = None
            for _ in range(max_attempts):
                line = process.stdout.readline()
                if not line:
                    break
                line = line.strip()
                # Skip log lines (they start with timestamps or contain log patterns)
                if line.startswith(("20:", "[")) or "info]" in line or "warn]" in line or "error]" in line:
                    print(f"  [Log] {line}")
                    continue
                # Try to parse as JSON
                try:
                    response = json.loads(line)
                    response_line = line
                    break
                except json.JSONDecodeError:
                    # Not JSON, might be part of a multi-line response or log
                    if line.startswith("{"):
                        response_line = line
                        break
                    print(f"  [Non-JSON] {line}")
            
            if response_line:
                response = json.loads(response_line)
                print(f"✓ Response received: {json.dumps(response, indent=2)}")
                
                # Verify it's a valid initialize response
                if response.get("id") == 1 and "result" in response:
                    print("✓ Initialize successful!")
                else:
                    print("⚠ Unexpected response format")
            else:
                print("✗ No JSON response received")
        except json.JSONDecodeError as e:
            print(f"✗ Failed to parse response: {e}")
            if response_line:
                print(f"Raw response: {response_line}")
        
        print("")
        
        # Test 2: Tools list request
        print("Test 2: Tools list request")
        tools_request = {
            "jsonrpc": "2.0",
            "id": 2,
            "method": "tools/list"
        }
        
        request_str = json.dumps(tools_request) + "\n"
        print(f"Sending: {request_str.strip()}")
        process.stdin.write(request_str)
        process.stdin.flush()
        
        try:
            # Read and filter log lines
            max_attempts = 10
            response_line = None
            for _ in range(max_attempts):
                line = process.stdout.readline()
                if not line:
                    break
                line = line.strip()
                # Skip log lines
                if line.startswith(("20:", "[")) or "info]" in line or "warn]" in line or "error]" in line:
                    print(f"  [Log] {line}")
                    continue
                # Try to parse as JSON
                try:
                    response = json.loads(line)
                    response_line = line
                    break
                except json.JSONDecodeError:
                    if line.startswith("{"):
                        response_line = line
                        break
                    print(f"  [Non-JSON] {line}")
            
            if response_line:
                response = json.loads(response_line)
                print(f"✓ Response received: {json.dumps(response, indent=2)}")
                
                # Verify it contains tools
                if response.get("id") == 2 and "result" in response:
                    tools = response.get("result", {}).get("tools", [])
                    print(f"✓ Found {len(tools)} tools")
                    for tool in tools[:3]:  # Show first 3 tools
                        print(f"  - {tool.get('name')}: {tool.get('description', 'N/A')}")
                else:
                    print("⚠ Unexpected response format")
            else:
                print("✗ No JSON response received")
        except json.JSONDecodeError as e:
            print(f"✗ Failed to parse response: {e}")
            if response_line:
                print(f"Raw response: {response_line}")
        
        print("")
        print("✓ Stdio test completed!")
        
    except Exception as e:
        print(f"✗ Error during testing: {e}")
        import traceback
        traceback.print_exc()
    finally:
        # Clean up
        process.terminate()
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()

if __name__ == "__main__":
    test_stdio()

