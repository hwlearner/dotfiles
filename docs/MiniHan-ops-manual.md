# MiniHan 运维手册

最后更新：2026-05-16

## 主机概览

- 主机名：`MiniHan`
- 系统：Windows 11 (10.0.26200)
- 用户：`minihan\han`，Administrators 组成员
- LAN IP：`192.168.3.10`（静态，网关 `192.168.3.1`）
- SSH：Mac 侧 `ssh han@192.168.3.10`，仅公钥认证
- Tailscale：Tailscale v1.98.1 (TBD)

## SSH 访问

| 项目 | 值 |
|------|-----|
| 端口 | 22 |
| 认证 | 公钥仅，密码和 KbdInteractive 禁用 |
| 服务 | `Automatic` 开机自启 |
| 防火墙 | 入站放行 |

## 网络

| 接口 | IP |
|------|-----|
| 以太网 2 | 静态 `192.168.3.10/24` (gw `192.168.3.1`) |
| 代理 | WinHTTP `http://192.168.1.10:7890` |
| 环境变量 | `HTTP_PROXY`=`HTTPS_PROXY`=`http://192.168.1.10:7890` |
| NO_PROXY | `localhost,127.0.0.1,192.168.3.0/24,.local` |

## 电源

- 休眠：关闭
- 睡眠 (S1/S2/S3)：禁用
- S0 Modern Standby：`ALLOWSTANDBY=0` 禁止进入
- 混合睡眠：关闭
- 无人值守超时：`0`（永不）

## Windows 更新

- Active Hours：08:00--02:00
- 登录用户时自动重启：禁止
- 模式：通知下载和安装

## 运行时

| 组件 | 版本 |
|------|------|
| Python | 3.12.10 |
| Node.js | 24.15.0 |
| uv | 0.11.14 |

## LangBot

- 版本：v4.9.3
- 路径：`C:\LangBot\`
- WebUI：`http://127.0.0.1:5300`
- 模型：`deepseek-v4-flash`（thinking 通过补丁禁用）
- 飞书：已接入（无 Webhook，流式回复关闭）
- MCP 服务器：`win-ops`（6 个工具，见 MCP 章节）

启动：schtasks `LangBot`（系统启动自动运行）

### DeepSeek thinking 补丁

文件：`src/langbot/pkg/provider/modelmgr/requesters/chatcmpl.py`

```python
extra_body["thinking"] = {"type": "disabled"}
```

## n8n

- 版本：2.20.9
- WebUI：`http://127.0.0.1:5678`
- 数据：`%USERPROFILE%\.n8n\`
- 启动：schtasks `n8n`（系统启动自动运行）

首次访问需创建管理员账户。

## 运维脚本 (Windows)

路径：`C:\Users\han\scripts\`

| 脚本 | 用途 |
|------|------|
| `win-status.ps1` | 系统状态 JSON |
| `win-service.ps1` | 服务 start/stop/restart/status |
| `win-eventlog.ps1` | 事件日志 tail |
| `win-ops-mcp.py` | MCP 服务器 (LangBot 调用) |
| `n8n-start.bat` | n8n 备用手动启动 |

## MCP 服务器 win-ops

6 个工具：

| 工具 | 执行位置 | 实现 |
|------|---------|------|
| `win_status` | Windows | PowerShell |
| `win_service` | Windows | PowerShell |
| `win_eventlog` | Windows | PowerShell |
| `arch_status` | Arch (192.168.1.10) | SSH → devops |
| `arch_service` | Arch | SSH → devops |
| `arch_podman` | Arch | SSH → devops |

SSH 密钥：`C:\Users\han\.ssh\id_ed25519_devops`（用于 devops@archan 受限账户）

## 计划任务

| 名称 | 触发 | 命令 |
|------|------|------|
| `LangBot` | ONSTART | `pythonw.exe C:\LangBot\main.py` |
| `n8n` | ONSTART | `n8n_svc.bat` |

## 常用命令

```cmd
rem 电源
powercfg /a
powercfg /qh SCHEME_CURRENT SUB_SLEEP

rem 端口
netstat -ano | findstr :5300
netstat -ano | findstr :5678

rem 进程
tasklist | findstr python

rem LangBot 日志
type C:\LangBot\data\logs\langbot-2026-05-15.log

rem 代理
curl http://192.168.1.10:7890
```
