# Proxmox VE 全功能方案：Windows 物理盘直通双启动、GPU 直通游戏、AI 智能体与宿主机智慧运维

## 概述

本方案旨在利用 **Proxmox VE** 作为虚拟化平台，在一台物理机上同时实现：

- **Windows 物理盘直通双启动**：Windows 直接安装在一块独立的物理硬盘上，既可**裸机双系统启动**获得完整性能，又可作为**虚拟机启动**由 Proxmox 管理。两种方式共用同一份 Windows 系统，状态完全同步。
- **GPU 直通**：在虚拟机启动模式下，将强力 GPU 直通给 Windows，原生游戏性能，完美兼容米哈游等反作弊游戏，借助 Sunshine/Moonlight 实现全屋串流。
- **AI 智能体 (OpenCode / Hermes)**：7×24 小时运行，提供 Web UI 和远程 API，用于 AI 编码、任务自动化等。
- **Headless Proxmox 宿主机**：Linux 宿主机完全无图形界面，仅通过 SSH 或 Proxmox Web 面板管理。
- **AI 智能体自动维护宿主机**：通过 Model Context Protocol (MCP) 让 Hermes 等智能体监控资源、执行备份/清理、响应告警，并用自然语言管理虚拟化环境。

整套系统灵活强大：想用原生 Windows 打游戏或干重活时直接物理启动；平时则通过 Proxmox 虚拟机使用 Windows，同时享受后台 AI 智能体服务。

---

## 1. GPU 直通配置

### 1.1 启用 IOMMU

`/etc/default/grub` 添加 `intel_iommu=on iommu=pt`（Intel）或 `amd_iommu=on iommu=pt`（AMD），然后 `update-grub`。

### 1.2 加载 VFIO 模块

`/etc/modules` 添加 `vfio`、`vfio_iommu_type1`、`vfio_pci`、`vfio_virqfd`，执行 `update-initramfs -u -k all` 并重启。

### 1.3 隔离直通显卡

用 `lspci -nn | grep -i nvidia` 获取 GPU 及 Audio 设备的 PCI ID，创建 `/etc/modprobe.d/vfio.conf`：

```
options vfio-pci ids=10de:2788,10de:22b1 disable_vga=1
```

重新生成 initramfs 并重启后，验证驱动为 `vfio-pci`。

---

## 2. Windows VM + GPU 直通 + Sunshine 串流

### 2.1 准备工作

1. 确定 Windows 物理硬盘的 by-id：`ls -la /dev/disk/by-id/`，找 NVMe 或 SSD 的完整 ID（如 `nvme-Samsung_SSD_xxx`）
2. 确认硬盘是 UEFI + GPT 格式（Windows 已装好时默认就是）

### 2.2 创建 Windows VM

在 Proxmox Web GUI 创建 VM：

- **OS**：不使用任何介质，Guest OS 选 Microsoft Windows 11/2022
- **System**：BIOS 选 **OVMF (UEFI)**，添加 EFI Storage + TPM v2.0
- **Disk**：不创建虚拟盘。Hardware → Add → Hard Disk → Bus/Device 选 **SATA**（Windows 原生支持），Path 填 `/dev/disk/by-id/你的硬盘ID`
- **CPU**：Type = `host`，4-8 核
- **Memory**：16 GB 起，关闭 Ballooning
- **Network**：模型选 **e1000**（Windows 自带驱动，后续可改 VirtIO）

**添加 GPU 直通**：Hardware → Add → PCI Device，选择已隔离的 NVIDIA GPU 及其 Audio 设备，勾选 All Functions、Primary GPU、ROM-Bar、PCI-Express。

### 2.3 启动与驱动完善

启动 VM 后：
1. Windows 直接进入桌面，Sunshine 自动随开机运行
2. 挂载 VirtIO 驱动 ISO，补装 VirtIO 网卡驱动
3. 装完后可关机，把 SATA 盘改回 **VirtIO Block**（更高性能），网卡改回 **VirtIO**

### 2.4 Moonlight 连接

外部设备安装 Moonlight，通过局域网 IP 配对 Sunshine，即可桌面级串流。

---

## 3. Sunshine / Moonlight 游戏串流

- Windows 虚拟机内安装 [Sunshine](https://github.com/LizardByte/Sunshine/releases)，配置 NVIDIA NVENC 编码器
- 客户端安装 Moonlight，局域网 IP 配对
- Headless 运行：无需接显示器，Windows 电源设置关闭显示器→从不，睡眠→从不

---

## 4. AI 智能体 (Hermes / OpenCode) 与宿主机运维

### 4.1 部署方式

| 方式 | 说明 |
|------|------|
| **LXC 容器**（推荐） | 资源隔离、轻量、易迁移 |
| 专用 VM | 需要 GPU 直通做本地推理时选用 |
| 宿主机直接安装 | 不推荐 |

### 4.2 MCP 集成 Proxmox

通过 Proxmox API Token + MCP Server，让 Hermes 调用 Proxmox API 执行 VM 管理、快照备份、资源监控等操作。

### 4.3 Host-MCP：宿主机运维工具

通过 MCP 协议让 Hermes 安全地管理 PVE 宿主机，无需 SSH，不走通用 shell。

**架构**：

```
Hermes (LXC 200)
    │ HTTP POST → 192.168.1.12:9120/
    ▼
host-mcp (systemd 服务, 用户 host-mcp, 非 root)
    ├── system_info      → CPU/内存/uptime 总览
    ├── disk_usage       → 磁盘用量
    ├── service_status   → 服务状态查询
    ├── check_updates    → apt 待更新列表
    ├── restart_service  → 重启白名单服务 (pveproxy/tailscaled/ssh/cron)
    ├── clear_logs       → 清理旧 journal 日志
    ├── run_upgrade      → apt update + dist-upgrade
    └── clean_packages   → apt autoremove
```

**安全边界**：
- 所有命令硬编码，不接受任意 command 字符串
- 进程以非 root 用户 `host-mcp` 运行，通过 `sudoers` 精确授权
- iptables 仅允许 LXC 容器 IP (192.168.1.13) 访问端口 9120
- 每个工具调用记录在 systemd journal 中

**部署位置**：`/opt/host-mcp/host-mcp.py`，通过 `systemctl` 管理。

### 4.3 多项目开发

每个项目一个 LXC 容器，源码通过宿主机 bind mount 挂入，删容器不丢代码。OpenCode 在每个项目容器内独立运行：

```bash
# 每个项目容器内
opencode serve &
opencode web --hostname 0.0.0.0 --port 4096 --password <密码>
```

### 4.4 项目容器模板

预装完整开发环境的 LXC 模板，新项目秒建：

| 分类 | 内容 |
|------|------|
| **基础** | git, curl, build-essential, cmake, ninja |
| **运行时** | Node.js 18, Python 3.12, OpenJDK 21, Rust 1.95, Lua 5.4, Cangjie 1.1.0 |
| **编辑器服务** | OpenCode, code-server 4.117 |
| **开发工具** | neovim, tmux, ripgrep, fd-find, bat, eza, fzf, starship, lazygit |
| **Shell** | zsh + starship prompt |
| **Git** | `user.name=田凝汉`, `user.email=sc.han@petalmail.com` |
| **环境** | CANGJIE_HOME、Cargo、.opencode/bin 均已加入 PATH |

**使用方式**：
```bash
# 克隆模板 → 项目容器
pct clone 208 <新ID> --hostname project-foo
pct set <新ID> --net0 name=eth0,bridge=vmbr0,ip=dhcp
pct start <新ID>

# 挂载源码（宿主机目录）
pct set <新ID> -mp0 /srv/projects/foo,mp=/workspace

# 进入容器启动 OpenCode
pct enter <新ID>
opencode web --hostname 0.0.0.0 --port 4096 --password <密码>
```

可通过 Tailscale 子网路由从外网直接访问。

---

## 5. 安全与远程访问 (Tailscale)

所有远程访问通过 **Tailscale** 虚拟局域网，无需公网 IP、端口转发或 DDNS。

### 5.1 架构：宿主机子网路由

```
外部设备 (任意网络, Tailscale IP)
        │
        ▼
  Tailscale 网络 (WireGuard 加密)
        │
        ▼
PVE 宿主机 (子网路由器, 192.168.1.0/24)
        │
        ▼
  LAN 192.168.1.0/24
        ├── 192.168.1.12  PVE Web 面板 (:8006)
        ├── 192.168.1.13  ai-agent (Hermes :9119)
        ├── 192.168.1.14  项目 A (OpenCode :4096)
        └── 192.168.1.15  项目 B (OpenCode :4096)
```

### 5.2 Tailscale Serve

Tailscale Serve 自动签发 Let's Encrypt 证书，直接转发：

```
浏览器 (HTTPS)
    │
    ▼
tailscale serve (:443, 自动 TLS 证书)
    │
    ▼
Hermes Dashboard (:9119)
```

**访问地址**：

| 服务 | 地址 |
|------|------|
| Hermes Dashboard (HTTPS) | `https://serverhan.tail3fd170.ts.net/` |
| PVE Web 面板 | `https://192.168.1.12:8006`（PVE 不支持子路径） |

---

## 6. 当前架构

```
                         Tailscale 网络
                    ┌─────────────────────┐
                    │  Mac / 手机 / 平板   │
                    └──────────┬──────────┘
                               │ Tailscale IP
                               ▼
+===========================================================+
|              Proxmox VE 宿主机 (ServerHan)                 |
|  PVE 9.1 · 静态 IP 192.168.1.12                           |
  |  Tailscale 子网路由 · HTTPS Serve (:443)                    |
|  host-mcp (:9120, iptables 仅允许 LXC 访问)               |
|===========================================================|
|                                                           |
|  +----- Windows VM (已部署) ------------+                  |
|  |  物理盘直通 + GPU 直通 + Sunshine    |                 |
|  +--+----------------------------------+                 |
|     |                                                    |
|  +--+---------------------------- LXC 200               |
|  |  ai-agent (192.168.1.13)                              |
|  |  · Hermes Agent v0.12.0                               |
|  |  · Hermes Dashboard (:9119)                           |
|  |  · Hermes WeChat Gateway                              |
|  |  · Proxmox MCP (9 tools，管理 VM)                     |
|  |  · host-mcp (8 tools，管理宿主机)                     |
|  +--------------------------------+                      |
|  +--+---------------------------- LXC 201 (未来)         |
|  |  项目 A (192.168.1.14)                                |
|  |  · OpenCode Web (:4096)                               |
|  +--------------------------------+                      |
|                                                           |
|  局域网: 192.168.1.x 直接可达                             |
|  外网: Tailscale 子网路由 + HTTPS Serve                  |
+===========================================================+
         |
         +-- 物理启动: BIOS 选择 Windows 硬盘原生启动
```

---

## 7. 当前完成状态

### 已完成

| 组件 | 详情 |
|------|------|
| PVE 9.1 | ZHITAI TiPlus7100 2TB，ext4 + LVM-thin，UEFI GRUB |
| 网络 | 静态 IP 192.168.1.12，桥接 vmbr0 |
| Tailscale | 子网路由 192.168.1.0/24，HTTPS Serve |
| Hermes Agent | LXC 200 (192.168.1.13)，Dashboard、WeChat Gateway、Proxmox MCP (9 tools)、host-mcp (8 tools) |
| host-mcp | PVE 宿主机运维 MCP，systemd 服务，iptables IP 白名单，sudoers 命令白名单 |
| WireGuard | 已替换为 Tailscale |

### 待完成

- [ ] 安装 OpenCode（LXC 容器内并行部署）
- [x] 创建 LXC 项目容器模板（多项目开发，模板 ID: 208）

---

## 8. 总结

- **Windows 物理盘直通**：双系统裸机启动 + 虚拟机模式，系统状态完全一致
- **GPU 直通**：原生游戏性能 + Sunshine 全屋串流
- **Hermes & OpenCode**：7×24 在线 AI 编码与自动化
- **MCP 宿主机运维**：AI 通过 Proxmox API 管理虚拟化环境
- **Tailscale**：免配置外网访问，HTTPS 证书自动签发

后续可扩展 NAS、Home Assistant、AI 模型训练等。
