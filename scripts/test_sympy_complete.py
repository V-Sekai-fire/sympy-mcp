#!/usr/bin/env python3
"""
Complete test of SymPy MCP server using SSE.
Captures and displays all SSE events including responses.
"""

import json
import requests
import threading
import time
import sys

BASE_URL = "http://localhost:8081"
SSE_URL = f"{BASE_URL}/sse"

session_id = None
responses = {}
response_lock = threading.Lock()

def sse_reader():
    """Read SSE events and display them"""
    global session_id
    
    try:
        headers = {
            "Accept": "text/event-stream",
            "mcp-protocol-version": "2025-06-18"
        }
        
        print("Connecting to SSE endpoint...")
        response = requests.get(SSE_URL, headers=headers, stream=True, timeout=30)
        response.raise_for_status()
        
        current_event = None
        current_data = None
        
        for line in response.iter_lines():
            if not line:
                # Empty line indicates end of event
                if current_event and current_data:
                    try:
                        data = json.loads(current_data)
                        
                        # Extract session ID
                        if "session_id" in data:
                            session_id = data["session_id"]
                            print(f"\n✓ Connected! Session ID: {session_id}\n")
                        elif "sessionId" in data:
                            session_id = data["sessionId"]
                            print(f"\n✓ Connected! Session ID: {session_id}\n")
                        
                        # Store response by request ID
                        if "id" in data:
                            request_id = data["id"]
                            with response_lock:
                                responses[request_id] = data
                            print(f"\n📨 Response for request {request_id}:")
                            print(json.dumps(data, indent=2))
                            print()
                    except json.JSONDecodeError:
                        print(f"Event {current_event}: {current_data}")
                
                current_event = None
                current_data = None
                continue
            
            line_str = line.decode('utf-8')
            
            if line_str.startswith("event: "):
                current_event = line_str[7:].strip()
            elif line_str.startswith("data: "):
                current_data = line_str[6:].strip()
            elif line_str.startswith("id: "):
                pass  # Event ID, can be ignored for now
                
    except Exception as e:
        print(f"SSE connection error: {e}")
        import traceback
        traceback.print_exc()

def send_request(method, params=None, request_id=1):
    """Send an MCP request"""
    global session_id
    
    # Wait for session ID if not available
    max_wait = 10
    waited = 0
    while not session_id and waited < max_wait:
        time.sleep(0.5)
        waited += 0.5
    
    if not session_id:
        print("Warning: No session ID available")
    
    payload = {
        "jsonrpc": "2.0",
        "id": request_id,
        "method": method
    }
    if params:
        payload["params"] = params
    
    headers = {
        "Content-Type": "application/json",
        "mcp-protocol-version": "2025-06-18"
    }
    if session_id:
        headers["mcp-session-id"] = session_id
    
    print(f"\n📤 Sending {method} (ID: {request_id})...")
    response = requests.post(BASE_URL, json=payload, headers=headers, timeout=10)
    
    if response.status_code == 202:
        print(f"   ✓ Request accepted (HTTP 202)")
        # Wait for SSE response
        max_wait = 10
        waited = 0
        while waited < max_wait:
            with response_lock:
                if request_id in responses:
                    return responses[request_id]
            time.sleep(0.5)
            waited += 0.5
        return {"error": "Timeout waiting for response"}
    else:
        try:
            return response.json()
        except:
            return {"error": f"HTTP {response.status_code}", "text": response.text}

def main():
    print("=" * 60)
    print("Testing SymPy MCP Server with SSE")
    print("=" * 60)
    
    # Start SSE reader thread
    sse_thread = threading.Thread(target=sse_reader, daemon=True)
    sse_thread.start()
    
    # Wait for connection
    time.sleep(2)
    
    # Test 1: Initialize
    print("\n" + "=" * 60)
    print("Test 1: Initialize")
    print("=" * 60)
    init_result = send_request("initialize", {
        "protocolVersion": "2025-06-18",
        "capabilities": {},
        "clientInfo": {"name": "test-client", "version": "1.0.0"}
    }, request_id=1)
    
    time.sleep(1)
    
    # Test 2: List tools
    print("\n" + "=" * 60)
    print("Test 2: List Tools")
    print("=" * 60)
    tools_result = send_request("tools/list", {}, request_id=2)
    
    time.sleep(1)
    
    # Test 3: Solve equation
    print("\n" + "=" * 60)
    print("Test 3: sympy_solve (x² - 4 = 0)")
    print("=" * 60)
    solve_result = send_request("tools/call", {
        "name": "sympy_solve",
        "arguments": {"equation": "x**2 - 4", "variable": "x"}
    }, request_id=3)
    
    time.sleep(1)
    
    # Test 4: Simplify
    print("\n" + "=" * 60)
    print("Test 4: sympy_simplify (x² + 2x + 1)")
    print("=" * 60)
    simplify_result = send_request("tools/call", {
        "name": "sympy_simplify",
        "arguments": {"expression": "x**2 + 2*x + 1"}
    }, request_id=4)
    
    time.sleep(1)
    
    # Test 5: Differentiate
    print("\n" + "=" * 60)
    print("Test 5: sympy_differentiate (x²)")
    print("=" * 60)
    diff_result = send_request("tools/call", {
        "name": "sympy_differentiate",
        "arguments": {"expression": "x**2", "variable": "x"}
    }, request_id=5)
    
    time.sleep(1)
    
    print("\n" + "=" * 60)
    print("Test Complete!")
    print("=" * 60)
    print("\nAll responses should be displayed above from the SSE stream.")
    
    # Keep connection alive a bit longer
    time.sleep(2)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nTest interrupted by user")
        sys.exit(0)

