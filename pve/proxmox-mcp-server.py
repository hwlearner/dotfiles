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

CLASH_API = "http://192.168.1.18:9090"
server = Server("proxmox-mcp")

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
    types.Tool(name="clash_proxies", description="List Clash proxies with delay", inputSchema={"type":"object","properties":{}}),
    types.Tool(name="clash_set_proxy", description="Switch Clash proxy group", inputSchema={"type":"object","properties":{"group":{"type":"string"},"proxy":{"type":"string"}},"required":["group","proxy"]}),
    types.Tool(name="ping_test", description="Ping a host", inputSchema={"type":"object","properties":{"host":{"type":"string"},"count":{"type":"integer"}},"required":["host"]}),
    types.Tool(name="win_ssh", description="Execute via SSH on Windows", inputSchema={"type":"object","properties":{"command":{"type":"string"}},"required":["command"]}),
    types.Tool(name="list_backups", description="List PVE backups", inputSchema={"type":"object","properties":{}}),
]
@server.list_tools()
async def list_tools(): return TOOLS

def cg(path):
    try:
        r = urllib.request.urlopen(f"{CLASH_API}{path}", timeout=10)
        return json.loads(r.read())
    except: return {"error": str(e)} if 'e' in dir() else {"error": "timeout"}

@server.call_tool()
async def call_tool(name, arguments):
    try:
        node = arguments.get("node", p.nodes.get()[0]["node"])
        n = lambda: p.nodes(node)
        q = lambda: n().qemu(arguments["vmid"])
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
            for _ in range(10): time.sleep(2); s=q().agent("exec-status").get(pid=pid); 
            if s.get("exitcode",-1)!=-1: break
            return [types.TextContent(type="text",text=json.dumps({"exitcode":s["exitcode"],"stdout":s.get("out-data",""),"stderr":s.get("err-data","")},indent=2,ensure_ascii=False))]
        if name=="clash_proxies":
            data=cg("/proxies"); proxies=data.get("proxies",{})
            groups={k:v for k,v in proxies.items() if v.get("type") in ("Selector","URLTest")}
            nodes={k:v for k,v in proxies.items() if v.get("type") in ("Vmess","Vless","Trojan","Shadowsocks")}
            result={"groups":{k:{"now":v.get("now","")} for k,v in groups.items()},
                    "nodes":{k:{"delay":v.get("history",[{}])[-1].get("delay",0) if v.get("history") else 0} for k,v in nodes.items()}}
            return [types.TextContent(type="text",text=json.dumps(result,indent=2,ensure_ascii=False))]
        if name=="clash_set_proxy":
            import http.client; conn=http.client.HTTPConnection("192.168.1.18",9090,timeout=10)
            conn.request("PUT",f"/proxies/{arguments['group']}",json.dumps({"name":arguments["proxy"]}),{"Content-Type":"application/json"})
            conn.getresponse(); return [types.TextContent(type="text",text=json.dumps({"ok":True},indent=2))]
        if name=="ping_test":
            r=subprocess.run(["ping","-c","4",arguments["host"]],capture_output=True,text=True,timeout=30)
            return [types.TextContent(type="text",text=f"exit={r.returncode}\n{r.stdout}")]
        if name=="win_ssh":
            r=subprocess.run(["ssh","-o","StrictHostKeyChecking=no","-o","ConnectTimeout=10",f"han@192.168.1.15",arguments["command"]],
                capture_output=True,text=True,timeout=30)
            return [types.TextContent(type="text",text=json.dumps({"exitcode":r.returncode,"stdout":r.stdout,"stderr":r.stderr},indent=2,ensure_ascii=False))]
        if name=="list_backups":
            try:
                b=p.nodes(node).storage("local").content.get(content="backup")
                return [types.TextContent(type="text",text=json.dumps(b,indent=2))]
            except:
                return [types.TextContent(type="text",text=json.dumps({"message":"No backups found"},indent=2))]
    except Exception as e: return [types.TextContent(type="text",text=f"Error: {e}")]

async def main():
    async with mcp.server.stdio.stdio_server() as (r,w):
        await server.run(r,w,InitializationOptions(server_name="proxmox-mcp",server_version="0.2.0",
            capabilities=server.get_capabilities(notification_options=NotificationOptions(),experimental_capabilities={})))

if __name__=="__main__": import asyncio; asyncio.run(main())
