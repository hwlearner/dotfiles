#!/usr/bin/env python3
"""win-ops-mcp - MCP server for Windows & Arch ops scripts."""
import json
import subprocess
import sys
from pathlib import Path

SCRIPTS_DIR = Path.home() / "scripts"
SCRIPTS_DIR_STR = str(SCRIPTS_DIR).replace("\\", "/")
SSH_KEY = str(Path.home() / ".ssh" / "id_ed25519_devops").replace("\\", "/")
SSH_OPTS = ["-o", "StrictHostKeyChecking=no", "-o", "ConnectTimeout=10"]

TOOLS = [
    {"name": "win_status", "desc": "Windows CPU/memory/disk/processes", "params": {}},
    {"name": "win_service", "desc": "Windows service start/stop/restart/status",
     "params": {"action": "start|stop|restart|status", "name": "service name"}},
    {"name": "win_eventlog", "desc": "Windows event log tail",
     "params": {"channel": "System/Application...", "tail": "number (optional)"}},
    {"name": "arch_status", "desc": "Arch Linux CPU/memory/disk/load", "params": {}},
    {"name": "arch_service", "desc": "Arch systemd unit start/stop/restart/status/enable/disable",
     "params": {"action": "start|stop|restart|status|enable|disable", "name": "unit name"}},
    {"name": "arch_podman", "desc": "Arch podman container ps/logs/start/stop/restart/inspect",
     "params": {"action": "ps|logs|start|stop|restart|inspect", "name": "container (optional for ps)"}},
]


def handle(req):
    mid, method = req.get("id"), req.get("method", "")
    if method == "initialize":
        return {"jsonrpc": "2.0", "id": mid,
                "result": {"protocolVersion": "2024-11-05", "capabilities": {"tools": {}},
                           "serverInfo": {"name": "win-ops-mcp", "version": "1.0.0"}}}
    if method == "tools/list":
        tool_list = []
        for t in TOOLS:
            props = {}
            for k, v in t["params"].items():
                props[k] = {"type": "string", "description": v}
            tool_list.append({"name": t["name"], "description": t["desc"],
                              "inputSchema": {"type": "object", "properties": props, "required": list(props.keys()) if "optional" not in t.get("params", {}) else [k for k in props if "optional" not in str(t["params"].get(k, ""))]}})
        return {"jsonrpc": "2.0", "id": mid, "result": {"tools": tool_list}}
    if method == "tools/call":
        name = req["params"]["name"]
        args = req["params"].get("arguments", {})
        try:
            result = run(name, args)
            return {"jsonrpc": "2.0", "id": mid, "result": {"content": [{"type": "text", "text": result}]}}
        except Exception as e:
            return {"jsonrpc": "2.0", "id": mid, "result": {"content": [{"type": "text", "text": f"Error: {e}"}], "isError": True}}
    return {"jsonrpc": "2.0", "id": mid, "error": {"code": -32601, "message": f"Unknown: {method}"}}


def run(name, args):
    if name == "win_status":
        return ps1("win-status.ps1")
    if name == "win_service":
        return ps1("win-service.ps1", "-action", args["action"], "-name", args["name"])
    if name == "win_eventlog":
        return ps1("win-eventlog.ps1", "-channel", args.get("channel", "System"), "-tail", str(args.get("tail", 20)))
    if name == "arch_status":
        return ssh_arch("arch-agent-status")
    if name == "arch_service":
        return ssh_arch("arch-agent-service", args["action"], args["name"])
    if name == "arch_podman":
        cmd = ["arch-agent-podman", args["action"]]
        if args.get("name"):
            cmd.append(args["name"])
        return ssh_arch(*cmd)
    raise ValueError(f"Unknown: {name}")


def ps1(*a):
    import os as _os
    tmp = SCRIPTS_DIR_STR + "/_ps1_out.tmp"
    script = SCRIPTS_DIR_STR + "/" + a[0]
    args = '"' + '" "'.join(str(x) for x in a[1:]) + '"' if len(a) > 1 else ''
    cmd = f'< NUL powershell -ExecutionPolicy Bypass -File "{script}" {args} > "{tmp}" 2>&1'
    _os.system(cmd)
    with open(tmp, encoding='utf-8', errors='replace') as f:
        result = f.read().strip()
    _os.unlink(tmp)
    return result


def ssh_arch(*a):
    import os as _os
    tmp = SCRIPTS_DIR_STR + "/_ssh_out.tmp"
    ssh = "C:/Windows/System32/OpenSSH/ssh.exe"
    args = " ".join(f'"{x}"' for x in a)
    cmd = f'< NUL "{ssh}" -o StrictHostKeyChecking=no -o ConnectTimeout=10 -i "{SSH_KEY}" devops@192.168.1.10 {args} > "{tmp}" 2>&1'
    _os.system(cmd)
    with open(tmp, encoding='utf-8', errors='replace') as f:
        result = f.read().strip()
    _os.unlink(tmp)
    return result


if __name__ == "__main__":
    buf = ""
    for line in sys.stdin:
        buf += line
        try:
            req = json.loads(buf)
            buf = ""
            sys.stdout.write(json.dumps(handle(req)) + "\n")
            sys.stdout.flush()
        except json.JSONDecodeError:
            continue
