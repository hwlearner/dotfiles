# dotfiles

我的跨平台开发环境配置。

## 目录结构

- `.zshrc`、`.zprofile`、`.tmux.conf`、`.gitconfig`：Shell、tmux 和 Git 的基础配置。
- `.aerospace.toml`：AeroSpace 窗口管理器配置。
- `.markdownlint.yaml`：共享的 markdownlint 规则。
- `nvim/`：来自 `~/.config/nvim` 的 Neovim 配置。
- `nvim-vscode/`：来自 `~/.config/nvim-vscode` 的 VS Code Neovim 桥接配置。
- `ghostty/`：来自 `~/.config/ghostty` 的 Ghostty 配置。
- `git/ignore`：来自 `~/.config/git/ignore` 的全局 Git 忽略规则。
- `vscode/`：VS Code 用户设置、快捷键、语言配置和扩展列表。
- `zed/`：Zed 用户设置、快捷键和全局任务配置。
- `autoconfig.yml`、`quickmarks`：仓库中保留的旧版 qutebrowser 配置。

## 跨平台分层

这个仓库按“公共配置保守、平台差异显式、本机覆盖不入库”的方式维护。

- 公共文件直接放在仓库根目录，例如 `.zshrc`、`.zshenv`、`.zprofile`、`.gitconfig`。
- 平台差异在文件内通过 `uname -s` 分支处理。
  macOS 只在 `Darwin` 分支里使用 Homebrew、OpenJDK、HarmonyOS SDK 等路径。
  Linux 只在 `Linux` 分支里处理 Gentoo/WSL 等 PATH 行为。
- 本机私有配置放在 home 目录的 local 文件里，不提交到仓库：
  - `~/.zshenv.local`
  - `~/.zprofile.local`
  - `~/.zshrc.local`
  - `~/.gitconfig.local`
- `.gitconfig` 只保留用户身份和 local include。
  `safe.directory`、credential helper、公司/个人项目差异等机器相关配置应放入 `~/.gitconfig.local`。

## 工具来源

开发工具按职责划分来源，不按“哪里装起来顺手”来划分。

- 系统包管理器：用于通用 CLI 工具和编译型工具链。
  macOS 使用 Homebrew，Gentoo/WSL 使用 Portage。
  例如：`gh`、`clangd`、`clang-format`、`ruff`、`shellcheck`、`marksman`、`cmake`、`ninja`。
- 用户级 `npm`：用于需要在 Neovim 之外也能复用的 Node 语言服务和 Markdown 工具。
  例如：`bash-language-server`、`markdown-toc`、`markdownlint-cli2`、`pyright`、`yaml-language-server`、`vscode-json-language-server`。
- Mason：用于只服务编辑器、不需要单独做系统级生命周期管理的工具。
  例如：`lua-language-server`、`stylua`、`taplo`、`rust-analyzer`、`shfmt`、`debugpy`、`codelldb`。

规则：

- 每个工具尽量只保留一个生效来源。
- 除非明确需要兜底，否则不要同时通过 Mason 和系统级/全局管理器安装同一个工具。
- PATH 必须按平台区分。
  macOS 只在 macOS 下使用 Homebrew 路径。
  Linux/WSL 不应继承 `/opt/homebrew/...` 这类 macOS 专用路径。
- 如果某个工具开始在 Neovim 之外也经常使用，就应当从 Mason 迁移到系统包管理器或用户级 `npm`。
- Neovim 的 Mason 去重逻辑按实际命令路径判断。
  只有当工具存在于 Mason 目录之外时，才会从 Mason 的安装列表里移除或设置 `mason = false`。
  这样 macOS 和 Linux 可以共用同一份配置，同时避免把 Mason 自己提供的工具误判成系统工具。

## macOS 开发环境

macOS 上用 Homebrew 复现基础开发工具：

```sh
brew bundle --file=Brewfile
```

`Brewfile` 只保留开发环境相关的 formula、cask 和 VS Code 扩展。
娱乐、游戏、临时测试应用不放入这个清单。

## 不纳入版本控制

机器状态、缓存、历史记录、SSH 密钥、应用令牌、VS Code 全局存储目录，以及下载得到的插件目录，都不应该进入这个仓库。

## Windows 下同步 VS Code 配置

在 Windows 上克隆本仓库后，可以运行 `scripts\sync-vscode-windows.cmd`，把已跟踪的 VS Code 配置复制到当前用户目录；如果本机可用 VS Code CLI，也会安装列出的扩展。

同步内容：

- `vscode/User/settings.json`、`keybindings.json`、`locale.json`
- `nvim-vscode/init.lua` 同步到 `%USERPROFILE%\.config\nvim-vscode\init.lua`
- `.markdownlint.yaml` 同步到 `%USERPROFILE%\.markdownlint.yaml`
- 在 VS Code CLI 可用时，通过 `code --install-extension` 安装 `vscode/extensions.txt` 中列出的扩展

常用参数：

- `scripts\sync-vscode-windows.cmd -WhatIf`：预览变更，不写入文件
- `scripts\sync-vscode-windows.cmd -InstallExtensions`：在传入其他参数时也安装扩展
- `scripts\sync-vscode-windows.cmd -CangjieHome D:\Developer\cangjie\current`：覆盖默认的仓颉 SDK 路径
- `scripts\sync-vscode-windows.cmd -NeovimPath "D:\Tools\Neovim\bin\nvim.exe"`：覆盖默认的 Neovim 路径

---

## Homelab: Proxmox VE All-in-One 家庭服务器


## 概述

本方案旨在利用 **Proxmox VE** 作为虚拟化平台，在一台物理机上构建 All-in-One 家庭服务器，整合游戏、AI、存储、智能家居：

- **Windows 物理盘直通双启动**：Windows 直接安装在一块独立的物理硬盘上，既可**裸机双系统启动**获得完整性能，又可作为**虚拟机启动**由 Proxmox 管理。两种方式共用同一份 Windows 系统，状态完全同步。
- **GPU 直通**：在虚拟机启动模式下，将强力 GPU 直通给 Windows，原生游戏性能，完美兼容米哈游等反作弊游戏，借助 Sunshine/Moonlight 实现全屋串流。
- **AI 智能体 (OpenClaw / OpenCode)**：7×24 小时运行，提供 Web UI 和远程 API，用于 AI 编码、任务自动化，通过 MCP 协议运维宿主机。
- **NAS 文件存储**：直通大容量机械硬盘，运行飞牛 OS / TrueNAS 提供 SMB 文件共享、DLNA 媒体服务、下载中心。
- **Home Assistant**：独立虚拟机作为智能家居中枢，统一管理全套华为智能家居设备，实现跨品牌联动。
- **Mihomo 透明网关**：旁路由模式为开发容器和需要代理的设备提供透明代理和智能分流。
- **Headless Proxmox 宿主机**：Linux 宿主机完全无图形界面，仅通过 SSH 或 Proxmox Web 面板管理。

整套系统灵活强大：想打游戏时物理启动或 VM 模式串流，平时后台运行 AI、NAS、HA 等服务。

---

## 硬件平台

| 组件 | 配置方案 | 核心思路 |
|------|----------|----------|
| **宿主机** | Headless 无头主机，纯 SSH/Web 管理 | 极致节能，全部硬件资源留给服务 |
| **存储 A (系统)** | 2TB NVMe SSD (PVE 宿主机) | 高速响应，专用于宿主机和 VM 系统 |
| **存储 B (游戏)** | 4TB NVMe SSD (整盘直通 Windows VM) | 原生性能，支持**虚拟机启动**和**物理机启动**，保证反作弊游戏兼容 |
| **存储 C (数据)** | 大容量机械硬盘 (直通 NAS VM) | 低成本大容量数据仓库，存放影音和备份 |
| **显卡（已通）** | NVIDIA RTX 4080 SUPER | **直通 Windows VM**，Sunshine 串流，完美原生性能 |

---

## 3. Sunshine / Moonlight 游戏串流

- Windows 虚拟机内安装 [Sunshine](https://github.com/LizardByte/Sunshine/releases)，配置 NVIDIA NVENC 编码器
- 客户端安装 Moonlight，局域网 IP 配对
- Headless 运行：无需接显示器，Windows 电源设置关闭显示器→从不，睡眠→从不

---

## 4. OpenClaw / OpenCode 与宿主机运维

### 4.1 部署方式

| 方式 | 说明 |
|------|------|
| **LXC 容器**（推荐） | 资源隔离、轻量、易迁移 |
| 专用 VM | 需要 GPU 直通做本地推理时选用 |
| 宿主机直接安装 | 不推荐 |

### 4.2 MCP 接口总览

OpenClaw 通过 Proxmox API Token + MCP Server 管理整个集群，当前注册了 **约 306 个工具**：

| 类别 | MCP 工具 | 说明 |
|------|----------|------|
| **Proxmox** | `list_nodes` | 列出所有节点 |
| | `list_vms` | 列出所有 VM |
| | `vm_status` | 查看 VM 状态 |
| | `node_status` | 节点资源使用 |
| | `start_vm` / `stop_vm` | 启停 VM |
| | `create_snapshot` / `list_snapshots` / `delete_snapshot` | VM 快照管理 |
| | `guest_exec` | Windows VM 内执行 PowerShell（通过 QEMU GA） |
| **Clash** | `clash_proxies` | 查看所有节点延迟和当前策略 |
| | `clash_set_proxy` | 切换 Clash 策略组到指定节点 |
| **Windows** | `win_ssh` | 通过 SSH 在 Windows 上执行命令（han 用户） |
| **网络** | `ping_test` | 从 OpenClaw LXC ping 任意主机 |
| **NAS** | `nas_status` | 查看 NAS 磁盘用量和服务状态 |
| | `nas_disk` | 查看 NAS 存储设备列表 |
| **OpenCode** | `opencode_run` | 在开发环境 LXC 中执行命令 |
| **备份** | `list_backups` | 查看 PVE 备份列表 |

### 4.3 Host-MCP：pve01 宿主机运维工具

通过 MCP 协议让 OpenClaw 安全地管理 PVE 宿主机，无需 SSH，不走通用 shell。

**架构**：

```
OpenClaw (LXC 200)
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
- iptables 仅允许 LXC 容器 IP (192.168.1.11) 访问端口 9120
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
| **用户** | 非 root 账号 `han` (sudo NOPASSWD)，日常开发用此账号 |
| **运行时** | Node.js 18, Python 3.12, OpenJDK 21, Rust 1.95, Lua 5.4, Cangjie 1.1.0 |
| **编辑器服务** | OpenCode (serve :4096), code-server (无密码 :8080)，rc.local 开机自启 |
| **编辑器** | neovim 0.12 + LazyVim（LSP / DAP / 格式化全套） |
| **开发工具** | tmux, ripgrep, fd-find, bat, eza, fzf, starship, lazygit |
| **Shell** | zsh + starship prompt |
| **Git** | `user.name=<Your Name>`, `user.email=<Your Email>` |
| **环境** | CANGJIE_HOME、Cargo、.opencode/bin 均已加入 PATH |

**使用方式**：
```bash
# 克隆模板 → 项目容器
pct clone 280 <新ID> --hostname project-foo
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

## 5. NAS 文件存储

### 5.1 方案

Debian 12 LXC，**Cockpit** Web 管理 + **Samba** 文件共享。

| 功能 | 说明 |
|------|------|
| **Web 面板** | `https://192.168.1.50:9090`（Cockpit） |
| **SMB 共享** | `smb://192.168.1.50/nas`（匿名读写） |
| **自动解压** | 拖入 `.zip`/`.rar`/`.tar.gz` 自动解压到同名子目录，支持备用密码 |
| **后续加硬盘** | 直通物理盘后手动挂载，通过 Cockpit 管理 |

### 5.2 部署架构

```
NAS (LXC 300)
├── Cockpit Web UI → 浏览器管理
├── SMB 文件共享   → 鸿蒙 / Mac / Windows
├── 自动解压服务   → inotify 监听 + unzip/unrar
└── 1TB 虚拟盘     → 后续可加物理盘直通
```

---

## 6. 智能家居 (Home Assistant)

### 6.1 部署方式

独立 VM，分配 2 核 + 4GB 内存，桥接网络获取独立 IP。

### 6.2 关键集成

| 集成 | 方式 |
|------|------|
| **华为智慧生活** | 通过 Home Assistant 社区 HACS 插件桥接，获取设备状态和控制 |
| **小艺语音联动** | HA 暴露实体到 HomeKit Bridge 或通过小艺训练自定义指令 |
| **跨品牌自动化** | 一个平台同时控制华为、米家等设备，编写自动化流程 |

### 6.3 访问方式

- 局域网直接访问 HA Web UI
- 通过 Tailscale 子网路由 + Tailscale Serve 从外网访问

---

## 7. 网络旁路由 (Mihomo)

### 7.1 架构

在 PVE 上部署 **Mihomo** 作为透明网关 LXC，为开发容器和需要代理的设备提供智能分流：

```
LAN 设备
    │ 网关 → 192.168.1.20 (router LXC 100)
    ▼
router LXC 100 (Mihomo, 192.168.1.20)
    ├── 国内流量 → 直连
    └── 海外流量 → Proxy -> Auto 低延迟节点
```

### 7.2 部署方式

- **LXC 100 `router`** 运行 Mihomo，静态 IP `192.168.1.20`
- HTTP/SOCKS5 混合代理端口 `:7890`，TPROXY `:7891`，DNS `:5353`
- `mihomo-gateway.service` 通过 nftables TPROXY 接管经 100 出口的 TCP/UDP
- 容器内不放全局代理环境变量；PVE 通过默认路由管理拓扑

---

## 8. 安全与远程访问

所有远程访问通过 **Tailscale** 虚拟局域网，无需公网 IP、端口转发或 DDNS。

### 8.1 架构：宿主机子网路由

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
        ├── 192.168.1.11  OpenClaw (:18789)
        ├── 192.168.1.20  Mihomo router (:7890/:7891/:5353)
        ├── 192.168.1.50  NAS (:9090/:445/:9121)
        ├── 192.168.1.100 Dev Template (:4096)
        └── 192.168.1.101 ESL Simulator (:4096)
```

### 8.2 Tailscale Serve

Tailscale Serve 自动签发 Let's Encrypt 证书，直接转发：

```
浏览器 (HTTPS)
    │
    ▼
tailscale serve (:443, 自动 TLS 证书)
    │
    ▼
OpenClaw Dashboard (:18789/claw/)
```

**访问地址**：

| 服务 | 地址 |
|------|------|
| OpenClaw Dashboard (HTTPS) | `https://serverhan.tail3fd170.ts.net/claw/` |
| PVE Web 面板 | `https://192.168.1.12:8006` |
| Home Assistant | 未部署 |

### 8.3 系统加固

- **PVE 防火墙**：启用内置防火墙，限制管理端口仅允许 Tailscale IP 访问
- **SSH**：禁止密码登录，仅允许密钥认证（`/etc/ssh/sshd_config` 中 `PasswordAuthentication no`）
- **Web 服务**：所有对外服务通过 Tailscale Serve 加密访问，不暴露公网端口
- **最小权限**：host-mcp 以非 root 用户运行，通过 sudoers 精确授权

### 8.4 数据备份

**3-2-1 备份策略**：
- **3** 份数据副本
- **2** 种不同存储介质
- **1** 份异地备份

**实现方案**：
- **Proxmox Backup Server**（PBS）：对关键 VM 做定时、加密的增量备份
- **NAS VM** 作为备份目标：定期将 PBS 备份同步到 NAS
- **异地备份**：通过 Tailscale 将关键数据备份到远程设备或云存储

| 备份对象 | 策略 | 频率 |
|----------|------|------|
| LXC 模板 | PBS 增量备份 | 每日 |
| OpenClaw Agent | PBS 增量备份 | 每日 |
| NAS 配置 | 导出配置文件 | 每次变更 |
| Home Assistant | PBS 快照 + 配置导出 | 每日 |

---

## 9. 当前架构

```
                         Tailscale 网络
                    ┌─────────────────────┐
                    │  Mac / 手机 / 平板   │
                    └──────────┬──────────┘
                               │ Tailscale IP
                               ▼
+===========================================================+
|              Proxmox VE 宿主机 (pve01)                 |
|  PVE 9.1 · 静态 IP 192.168.1.12                        |
|  Tailscale 子网路由 · HTTPS Serve (:443)                  |
|  host-mcp (:9120, iptables 仅允许 LXC 访问)               |
|===========================================================|
|                                                           |
|  +----- Windows VM (已部署) ------------+                 |
|  |  物理盘直通 + GPU 直通 + Sunshine    |                |
|  +--+----------------------------------+                 |
|     |                                                    |
|  +--+---------------------------- LXC 200               |
|  |  ai-agent (192.168.1.11)                            |
|  |  · OpenClaw Dashboard (:18789/claw/)                  |
|  |  · Telegram / QQBot / Weixin 插件                     |
|  |  · proxmox-mcp 包版 + nas-mcp                         |
|  +--------------------------------+                      |
|  +--+---------------------------- LXC 280 (模板)         |
|  |  Dev Template (192.168.1.100)                       |
|  |  · OpenCode Web (:4096)                               |
|  +--------------------------------+                      |
|  +--+---------------------------- LXC 300 (已部署)          |
|  |  NAS (192.168.1.50)                                    |
|  |  · Cockpit Web (:9090) / SMB 共享                       |
|  |  · 1TB 存储（可加物理盘直通）                            |
|  +--------------------------------+                      |
|  +--+---------------------------- VM (规划中)            |
|  |  Home Assistant (未部署)                            |
|  |  · 华为智能家居桥接                                   |
|  |  · 跨品牌自动化                                       |
|  +--------------------------------+                      |
|  +--+---------------------------- LXC 100 (已部署)         |
|  |  Mihomo router (192.168.1.20)                         |
|  |  · HTTP/SOCKS5 (:7890) · TPROXY (:7891) · DNS (:5353)  |
|  |  · Proxy -> Auto 低延迟节点，未配置高优域名覆盖        |
|  +--------------------------------+                      |
|                                                           |
|  局域网: 192.168.1.x 直接可达                          |
|  外网: Tailscale 子网路由 + HTTPS Serve                  |
+===========================================================+
         |
         +-- 物理启动: BIOS 选择 Windows 硬盘原生启动
```

---

## 10. 当前完成状态

### 已完成

| 组件 | 详情 |
|------|------|
| PVE 9.1 | NVMe 2TB，ext4 + LVM-thin，UEFI GRUB，内核 6.17.x |
| 网络 | 静态 IP 192.168.1.12，桥接 vmbr0 |
| Tailscale | 子网路由 192.168.1.0/24，HTTPS Serve |
| OpenClaw Agent | LXC 200 (192.168.1.11)，Dashboard、渠道插件、Proxmox MCP、nas-mcp |
| host-mcp | PVE 宿主机运维 MCP，systemd 服务，iptables IP 白名单，sudoers 命令白名单 |
| Windows VM | 物理盘直通 + VirtIO SCSI + VirtIO 网卡 + RTX 4080 直通 + Sunshine 串流 |
| NAS | LXC 300 (192.168.1.50)，Cockpit Web 管理 + SMB 文件共享，1TB 存储 |
| LXC 项目模板 | 预装 OpenCode、Neovim LazyVim、多语言运行时的开发环境模板 |
| SSH 加固 | 已禁用密码登录，仅密钥认证 |

### 待完成

- [x] 安装 OpenCode（LXC 容器内并行部署）
- [x] 部署 NAS（Cockpit + Samba，LXC 300）
- [x] 部署 Mihomo 透明网关（LXC 100，Proxy -> Auto，无高优域名覆盖）
- [ ] 部署 Home Assistant VM
- [ ] 配置 Proxmox Backup Server (PBS) 备份策略
- [ ] 配置 3-2-1 异地备份

---

## 11. 总结

- **Windows 物理盘直通**：双系统裸机启动 + 虚拟机模式，系统状态完全一致
- **GPU 直通**：原生游戏性能 + Sunshine 全屋串流
- **OpenClaw & OpenCode**：7×24 在线 AI 编码与自动化
- **NAS**：Cockpit + Samba LXC，SMB 共享 + 自动解压
- **Home Assistant**：华为智能家居中枢，跨品牌联动
- **Mihomo 网关**：透明代理，智能分流
- **MCP 宿主机运维**：AI 通过 Proxmox API 管理虚拟化环境
- **Tailscale**：免配置外网访问，HTTPS 证书自动签发
- **3-2-1 备份**：PBS 加密增量备份 + 异地容灾
