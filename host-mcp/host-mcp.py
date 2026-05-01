import subprocess
import platform
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent
import asyncio
import uvicorn
import logging
from starlette.applications import Starlette
from starlette.responses import Response, StreamingResponse
from starlette.routing import Route
from starlette.requests import Request
import json

logging.basicConfig(level=logging.INFO, format='%(asctime)s %(message)s')
logger = logging.getLogger(__name__)

ALLOWED_SERVICES = {"nginx", "pveproxy", "tailscaled", "ssh", "cron"}

def _run(cmd, use_sudo=False):
    if use_sudo:
        cmd = ["sudo"] + cmd
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
    if r.returncode != 0:
        return f"[exit={r.returncode}]\n{r.stdout}\n{r.stderr}"
    return r.stdout or "(ok)"

TOOLS = [
    Tool(name="system_info", description="Show CPU, memory and uptime overview", inputSchema={"type":"object","properties":{}}),
    Tool(name="disk_usage", description="Show disk usage for all mount points", inputSchema={"type":"object","properties":{}}),
    Tool(name="service_status", description="Check if a systemd service is running", inputSchema={"type":"object","properties":{"service_name":{"type":"string"}},"required":["service_name"]}),
    Tool(name="check_updates", description="List available package updates (apt)", inputSchema={"type":"object","properties":{}}),
    Tool(name="restart_service", description="Restart a systemd service (allowed services only)", inputSchema={"type":"object","properties":{"service_name":{"type":"string"}},"required":["service_name"]}),
    Tool(name="clear_logs", description="Remove systemd journal logs older than N days", inputSchema={"type":"object","properties":{"days":{"type":"integer","default":7}}}),
    Tool(name="run_upgrade", description="Run apt update and apt dist-upgrade", inputSchema={"type":"object","properties":{}}),
    Tool(name="clean_packages", description="Remove unused packages with apt autoremove", inputSchema={"type":"object","properties":{}}),
]

def call_tool(name, arguments):
    if name == "system_info":
        host = platform.node()
        uname = platform.uname()
        mem = _run(["free", "-h"])
        uptime = _run(["uptime"])
        load = _run(["cat", "/proc/loadavg"])
        return f"host: {host}\nos: {uname.system} {uname.release}\n\n=== memory ===\n{mem}\n=== uptime ===\n{uptime}\n=== loadavg ===\n{load}"
    elif name == "disk_usage":
        return _run(["df", "-h", "-x", "tmpfs", "-x", "devtmpfs"])
    elif name == "service_status":
        return _run(["systemctl", "is-active", arguments["service_name"]])
    elif name == "check_updates":
        _run(["apt", "update"], use_sudo=True)
        return _run(["apt", "list", "--upgradable"])
    elif name == "restart_service":
        svc = arguments["service_name"]
        if svc not in ALLOWED_SERVICES:
            return f"denied: '{svc}' not in allowed list ({', '.join(sorted(ALLOWED_SERVICES))})"
        return _run(["systemctl", "restart", svc], use_sudo=True)
    elif name == "clear_logs":
        days = arguments.get("days", 7)
        return _run(["journalctl", "--vacuum-time", f"{days}d"], use_sudo=True)
    elif name == "run_upgrade":
        out = _run(["apt", "update"], use_sudo=True)
        out += "\n" + _run(["apt", "dist-upgrade", "-y"], use_sudo=True)
        return out
    elif name == "clean_packages":
        return _run(["apt", "autoremove", "--purge", "-y"], use_sudo=True)
    return f"unknown tool: {name}"

def make_response(id, result=None, error=None):
    resp = {"jsonrpc": "2.0", "id": id}
    if error:
        resp["error"] = error
    else:
        resp["result"] = result
    return Response(json.dumps(resp), media_type="application/json")

async def mcp_endpoint(request: Request):
    body = await request.json()
    method = body.get("method", "")
    req_id = body.get("id")
    logger.info(f"MCP request: {method}")

    if method == "initialize":
        return make_response(req_id, {
            "protocolVersion": "2024-11-05",
            "capabilities": {"tools": {}},
            "serverInfo": {"name": "host-mcp", "version": "1.0.0"}
        })
    elif method == "tools/list":
        return make_response(req_id, {"tools": [t.model_dump() for t in TOOLS]})
    elif method == "tools/call":
        params = body.get("params", {})
        tool_name = params.get("name", "")
        arguments = params.get("arguments", {})
        result_text = call_tool(tool_name, arguments)
        return make_response(req_id, {
            "content": [{"type": "text", "text": result_text}]
        })
    elif method == "notifications/initialized":
        return Response(status_code=200)
    else:
        return make_response(req_id, error={"code": -32601, "message": f"unknown method: {method}"})

app = Starlette(debug=False, routes=[
    Route("/", endpoint=mcp_endpoint, methods=["POST"]),
    Route("/sse", endpoint=mcp_endpoint, methods=["POST"]),
])

if __name__ == "__main__":
    logger.info("host-mcp starting on 192.168.1.12:9120")
    uvicorn.run(app, host="192.168.1.12", port=9120, log_level="info")
