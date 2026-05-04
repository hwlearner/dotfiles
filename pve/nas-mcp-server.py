#!/usr/bin/env python3
"""NAS MCP Server - lightweight MCP over HTTP"""
import json, subprocess, logging
from starlette.applications import Starlette
from starlette.routing import Route
from starlette.requests import Request
from starlette.responses import JSONResponse
import uvicorn

logger = logging.getLogger("nas-mcp")
logging.basicConfig(level=logging.INFO)

TOOLS = [
    {"name": "nas_df", "description": "NAS disk usage", "inputSchema": {"type":"object","properties":{}}},
    {"name": "nas_lsblk", "description": "List block devices", "inputSchema": {"type":"object","properties":{}}},
    {"name": "nas_services", "description": "NAS service status", "inputSchema": {"type":"object","properties":{}}},
    {"name": "nas_reload_smb", "description": "Reload Samba", "inputSchema": {"type":"object","properties":{}}},
]

def handle_tool(name):
    if name == "nas_df":
        r = subprocess.run(["df","-h","/srv/nas"], capture_output=True, text=True)
        return [{"type":"text","text":r.stdout}]
    if name == "nas_lsblk":
        r = subprocess.run(["lsblk","-o","NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT"], capture_output=True, text=True)
        return [{"type":"text","text":r.stdout}]
    if name == "nas_services":
        r = subprocess.run("systemctl is-active smbd cockpit auto-extract 2>/dev/null", shell=True, capture_output=True, text=True)
        return [{"type":"text","text":r.stdout}]
    if name == "nas_reload_smb":
        r = subprocess.run(["systemctl","reload","smbd"], capture_output=True)
        return [{"type":"text","text":"ok" if r.returncode==0 else "fail"}]
    return [{"type":"text","text":f"Unknown: {name}"}]

def make_err(id, msg):
    return JSONResponse({"jsonrpc":"2.0","id":id,"error":{"code":-32601,"message":msg}})

async def mcp_endpoint(request: Request):
    body = await request.json()
    method = body.get("method","")
    params = body.get("params",{})
    rid = body.get("id", 1)
    
    if method == "initialize":
        return JSONResponse({"jsonrpc":"2.0","id":rid,"result":{
            "protocolVersion":"2025-03-26",
            "capabilities":{"experimental":{},"prompts":{},"resources":{},"tools":{}},
            "serverInfo":{"name":"nas-mcp","version":"0.1.0"}
        }})
    if method == "notifications/initialized":
        return JSONResponse({"jsonrpc":"2.0","id":rid,"result":{}})
    if method == "tools/list":
        return JSONResponse({"jsonrpc":"2.0","id":rid,"result":{"tools":TOOLS}})
    if method == "tools/call":
        name = params.get("name","")
        content = handle_tool(name)
        return JSONResponse({"jsonrpc":"2.0","id":rid,"result":{"content":content,"isError":False}})
    if method == "ping":
        return JSONResponse({"jsonrpc":"2.0","id":rid,"result":{}})
    
    return make_err(rid, f"Unknown method: {method}")

app = Starlette(routes=[
    Route("/", endpoint=mcp_endpoint, methods=["POST"]),
])

if __name__ == "__main__":
    logger.info("NAS MCP starting on 0.0.0.0:9121")
    uvicorn.run(app, host="0.0.0.0", port=9121, log_level="info")
