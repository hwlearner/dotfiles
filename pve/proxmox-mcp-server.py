#!/usr/bin/env python3
import json, os, sys, time, subprocess, urllib.request
from proxmoxer import ProxmoxAPI
from mcp.server import Server, NotificationOptions
from mcp.server.models import InitializationOptions
import mcp.server.stdio
import mcp.types as types

p = ProxmoxAPI(os.environ.get("PROXMOX_HOST","192.168.1.12"),
    user=os.environ.get("PROXMOX_USER","hermes-mcp@pve"),
    token_name=os.environ.get("PROXMOX_TOKEN_NAME","mcp-token"),
    token_value=os.environ.get("PROXMOX_TOKEN_VALUE"), verify_ssl=False)

server = Server("proxmox-mcp")

# === TOOLS ===
TOOLS = [
    types.Tool(name="list_nodes", description="List Proxmox nodes", inputSchema={"type":"object","properties":{}}),
    types.Tool(name="list_vms", description="List all VMs", inputSchema={"type":"object","properties":{"node":{"type":"string"}}}),
    types.Tool(name="vm_status", description="Get VM status", inputSchema={"type":"object","properties":{"vmid":{"type":"integer"},"node":{"type":"string"}},"required":["vmid","node"]}),
    types.Tool(name="node_status", description="Node resource usage", inputSchema={"type":"object","properties":{"node":{"type":"string"}}}),
    types.Tool(name="start_vm", description="Start VM", inputSchema={"type":"object","properties":{"vmid":{"type":"integer"},"node":{"type":"string"}},"required":["vmid","node"]}),
    types.Tool(name="stop_vm", description="Stop VM", inputSchema={"type":"object","properties":{"vmid":{"type":"integer"},"node":{"type":"string"}},"required":["vmid","node"]}),
    types.Tool(name="create_snapshot", description="Create VM snapshot", inputSchema={"type":"object","properties":{"vmid":{"type":"integer"},"node":{"type":"string"},"snapname":{"type":"string"}},"required":["vmid","node","snapname"]}),
    types.Tool(name="list_snapshots", description="List VM snapshots", inputSchema={"type":"object","properties":{"vmid":{"type":"integer"},"node":{"type":"string"}},"required":["vmid","node"]}),
    types.Tool(name="delete_snapshot", description="Delete VM snapshot", inputSchema={"type":"object","properties":{"vmid":{"type":"integer"},"node":{"type":"string"},"snapname":{"type":"string"}},"required":["vmid","node","snapname"]}),
    types.Tool(name="guest_exec", description="Run PowerShell in Windows VM", inputSchema={"type":"object","properties":{"vmid":{"type":"integer"},"node":{"type":"string"},"command":{"type":"string"}},"required":["vmid","node","command"]}),
    types.Tool(name="clash_proxies", description="List Clash proxies", inputSchema={"type":"object","properties":{}}),
    types.Tool(name="clash_set_proxy", description="Switch Clash proxy", inputSchema={"type":"object","properties":{"group":{"type":"string"},"proxy":{"type":"string"}},"required":["group","proxy"]}),
    types.Tool(name="ping_test", description="Ping a host", inputSchema={"type":"object","properties":{"host":{"type":"string"},"count":{"type":"integer"}},"required":["host"]}),
    types.Tool(name="win_ssh", description="Execute on Windows via SSH", inputSchema={"type":"object","properties":{"command":{"type":"string"}},"required":["command"]}),
    types.Tool(name="nas_ls", description="List NAS directory", inputSchema={"type":"object","properties":{"path":{"type":"string","description":"Path like /srv/nas"}},"required":["path"]}),
    types.Tool(name="nas_tree", description="Show NAS directory tree", inputSchema={"type":"object","properties":{"path":{"type":"string"}},"required":["path"]}),
    types.Tool(name="nas_mv", description="Move/rename NAS files", inputSchema={"type":"object","properties":{"src":{"type":"string"},"dst":{"type":"string"}},"required":["src","dst"]}),
    types.Tool(name="nas_rm", description="Delete NAS files/folders", inputSchema={"type":"object","properties":{"path":{"type":"string"}},"required":["path"]}),
    types.Tool(name="opencode_run", description="Run command in dev environment", inputSchema={"type":"object","properties":{"command":{"type":"string"}},"required":["command"]}),
    types.Tool(name="list_backups", description="List PVE backups", inputSchema={"type":"object","properties":{}}),
]
@server.list_tools()
async def list_tools(): return TOOLS

SSH_BASE = ["ssh","-i","/home/claw/.ssh/id_ed25519","-o","IdentitiesOnly=yes","-o","StrictHostKeyChecking=no","-o","BatchMode=yes","-o","ConnectTimeout=15","-o","ConnectionAttempts=3"]
SSH_NAS = SSH_BASE + ["han@192.168.1.50"]

@server.call_tool()
async def call_tool(name, arguments):
    try:
        node = arguments.get("node", p.nodes.get()[0]["node"])
        n = lambda: p.nodes(node); q = lambda: n().qemu(arguments["vmid"])
        if name=="list_nodes": return [types.TextContent(type="text",text=json.dumps(p.nodes.get(),indent=2))]
        if name=="list_vms": return [types.TextContent(type="text",text=json.dumps(p.cluster.resources.get(type="vm"),indent=2))]
        if name=="vm_status": return [types.TextContent(type="text",text=json.dumps(q().status.current.get(),indent=2))]
        if name=="node_status": return [types.TextContent(type="text",text=json.dumps(n().status.get(),indent=2))]
        if name=="start_vm": q().status.start.post(); return [types.TextContent(type="text",text=json.dumps({"ok":True},indent=2))]
        if name=="stop_vm": q().status.stop.post(); return [types.TextContent(type="text",text=json.dumps({"ok":True},indent=2))]
        if name=="create_snapshot": q().snapshot.post(snapname=arguments["snapname"]); return [types.TextContent(type="text",text=json.dumps({"ok":True},indent=2))]
        if name=="list_snapshots": return [types.TextContent(type="text",text=json.dumps(q().snapshot.get(),indent=2))]
        if name=="delete_snapshot": q().snapshot(arguments["snapname"]).delete(); return [types.TextContent(type="text",text=json.dumps({"ok":True},indent=2))]
        if name=="guest_exec":
            r=q().agent.exec.post(command=["powershell","-Command",arguments["command"]]); pid=r["pid"]
            for _ in range(10):
                time.sleep(2)
                s=q().agent("exec-status").get(pid=pid)
                if s.get("exitcode",-1)!=-1: break
            return [types.TextContent(type="text",text=json.dumps({"exitcode":s["exitcode"],"stdout":s.get("out-data",""),"stderr":s.get("err-data","")},indent=2,ensure_ascii=False))]
        if name=="clash_proxies":
            r=urllib.request.urlopen("http://192.168.1.18:9090/proxies",timeout=10); d=json.loads(r.read())
            groups={k:{"now":v.get("now","")} for k,v in d.get("proxies",{}).items() if v.get("type") in ("Selector","URLTest")}
            nodes={k:{"delay":v.get("history",[{}])[-1].get("delay",0) if v.get("history") else 0} for k,v in d.get("proxies",{}).items() if v.get("type") in ("Vmess","Vless","Trojan","Shadowsocks","Hysteria2")}
            return [types.TextContent(type="text",text=json.dumps({"groups":groups,"nodes":nodes},indent=2,ensure_ascii=False))]
        if name=="clash_set_proxy":
            conn=http.client.HTTPConnection("192.168.1.18",9090,timeout=10); conn.request("PUT","/proxies/"+arguments["group"],json.dumps({"name":arguments["proxy"]}),{"Content-Type":"application/json"}); conn.getresponse()
            return [types.TextContent(type="text",text=json.dumps({"ok":True},indent=2))]
        if name=="ping_test":
            r=subprocess.run(["ping","-c","4",arguments["host"]],capture_output=True,text=True,timeout=30)
            return [types.TextContent(type="text",text=f"exit={r.returncode}\n{r.stdout}")]
        if name=="win_ssh":
            r=subprocess.run(SSH_BASE+["han@192.168.1.15",arguments["command"]],capture_output=True,text=True,timeout=30)
            return [types.TextContent(type="text",text=json.dumps({"exitcode":r.returncode,"stdout":r.stdout,"stderr":r.stderr},indent=2,ensure_ascii=False))]
        # NAS file tools
        if name=="nas_ls":
            r=subprocess.run(SSH_NAS+["ls -lah "+arguments["path"]],capture_output=True,text=True,timeout=15)
            return [types.TextContent(type="text",text=json.dumps({"stdout":r.stdout[:2000],"stderr":r.stderr[:500]},indent=2,ensure_ascii=False))]
        if name=="nas_tree":
            r=subprocess.run(SSH_NAS+["find "+arguments["path"]+" -maxdepth 2 | head -50"],capture_output=True,text=True,timeout=15)
            return [types.TextContent(type="text",text=json.dumps({"stdout":r.stdout[:2000]},indent=2,ensure_ascii=False))]
        if name=="nas_mv":
            r=subprocess.run(SSH_NAS+["mv -v \""+arguments["src"]+"\" \""+arguments["dst"]+"\" 2>&1"],capture_output=True,text=True,timeout=15)
            return [types.TextContent(type="text",text=json.dumps({"stdout":r.stdout,"stderr":r.stderr},indent=2,ensure_ascii=False))]
        if name=="nas_rm":
            r=subprocess.run(SSH_NAS+["rm -rfv \""+arguments["path"]+"\" 2>&1"],capture_output=True,text=True,timeout=15)
            return [types.TextContent(type="text",text=json.dumps({"stdout":r.stdout,"stderr":r.stderr},indent=2,ensure_ascii=False))]
        if name=="opencode_run":
            r=subprocess.run(SSH_BASE+["han@192.168.1.101","cd /home/han/ESL_SIMULATOR && "+arguments["command"]],capture_output=True,text=True,timeout=120)
            return [types.TextContent(type="text",text=json.dumps({"exitcode":r.returncode,"stdout":r.stdout,"stderr":r.stderr},indent=2,ensure_ascii=False))]
        if name=="list_backups":
            try:
                b=p.nodes(node).storage("local").content.get(content="backup")
                return [types.TextContent(type="text",text=json.dumps(b,indent=2))]
            except: return [types.TextContent(type="text",text=json.dumps({"message":"No backups found"},indent=2))]
    except Exception as e: return [types.TextContent(type="text",text=f"Error: {e}")]

async def main():
    async with mcp.server.stdio.stdio_server() as (r,w):
        await server.run(r,w,InitializationOptions(server_name="proxmox-mcp",server_version="0.3.0",
            capabilities=server.get_capabilities(notification_options=NotificationOptions(),experimental_capabilities={})))
if __name__=="__main__": import asyncio; asyncio.run(main())
