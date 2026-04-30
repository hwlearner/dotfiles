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

## 1. 硬件要求

| 组件 | 最低配置 | 推荐配置 |
|------|----------|----------|
| **CPU** | 支持 VT-d (Intel) / AMD-Vi (AMD)，4核或以上 | 6核＋，近期 Intel/AMD 均支持 |
| **主板** | 支持 IOMMU 分组，最好有 ACS 分离能力 | 靠谱的 B550/X570 或 Z690/Z790 |
| **内存** | 32 GB | 64 GB（16 GB 给 Windows，其余用于宿主机、LXC 和 AI 任务） |
| **显卡** | **两张**：一张用于宿主机显示（或核显），另一张直通给 Windows | - 核显 + NVIDIA RTX 4060 以上<br/>- 或双独显（A 卡亮机 + N 卡游戏） |
| **存储** | **三块** SSD/HDD：<br/>① Proxmox 系统盘<br/>② Windows 专用物理盘 (建议 NVMe SSD)<br/>③ 共享数据盘（可选） | 512 GB NVMe (Proxmox) + 1 TB NVMe (Windows) |
| **网络** | 千兆有线，路由器支持 DHCP 保留/静态 IP | 2.5 GbE 或 Wi-Fi 6 备用 |
| **外围设备** | USB 键盘（应急操作） | — |

> **注意**：NVIDIA 消费级显卡（GeForce）现已解除虚拟化限制，可正常直通。仍建议避开已知存在问题的型号（如 RTX 3050）。
>
> **关于 B760M 芯片组**：消费级 B760 主板**无 BMC/IPMI 远程管理功能**，不具备独立远程 KVM。Headless 场景下的键盘问题可通过以下方式解决：
> - Moonlight 串流提供完整键盘鼠标操作（需 Windows 已运行）
> - Windows 屏幕键盘（`Win+R → osk`）作为备用输入
> - 准备一个 USB 键盘备用（十几元，插上装完就闲置）
> - 见 **2.3 替代安装方案**：在已有 Windows 中通过 VMware VM 直通物理盘安装 Proxmox

---

## 2. Proxmox VE 安装与基础配置

### 2.1 安装 Proxmox VE
1. 从 [proxmox.com](https://www.proxmox.com/) 下载最新 ISO，制作启动盘。
2. 安装时选择**第一块磁盘**（Proxmox 系统盘），文件系统推荐 **ext4** 或 **ZFS**。
3. 设置静态 IP、root 密码和邮箱。
4. 完成后浏览器访问 `https://<宿主机IP>:8006`。

### 2.2 初始更新与存储规划
```bash
apt update && apt dist-upgrade -y
```
在 Web GUI 中：
- **local** (Directory)：存放 ISO、CT模板。
- **local-lvm** (LVM-Thin)：存放虚拟机磁盘（Windows VM 本身不在此创建虚拟磁盘，但其他 VM/CT 可用）。
- **Windows 物理盘** (`/dev/nvme1n1` 或 `/dev/sdb`)：后面将以直通方式分配给 Windows VM，**不要对其进行分区或挂载**。

### 2.3 替代方案：通过 VMware Workstation VM 安装 Proxmox（Headless 场景）

如果机器完全 headless（无键盘/无显示器），可以在已有的 Windows 系统中用 VMware Workstation Pro 将 Proxmox 直接安装到目标物理盘，**全程无需物理键盘、无需 USB 启动盘**。

#### 2.3.1 下载 VMware Workstation Pro

VMware Workstation Pro 自 2024 年起已免费供个人使用：

1. 访问 [Broadcom 下载页面](https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware+Workstation+Pro)
2. 注册 Broadcom 账号即可下载，无需付费。

#### 2.3.2 创建 VM 并直通物理目标盘

1. **下载 Proxmox VE ISO**：
   ```
   https://enterprise.proxmox.com/iso/proxmox-ve_9.1-1.iso
   ```
2. 新建 VM，Guest OS 选择 **Linux → Debian 12.x x64**
3. **不创建虚拟磁盘**：将 Bus/Device 设为「无」
4. CPU 2 核、内存 4 GB、网络选 NAT（仅用于安装）
5. 挂载 Proxmox ISO 到 CD/DVD 驱动器
6. 手动添加物理磁盘：
   - VM Settings → Add → Hard Disk → Physical disk
   - 选择目标 Proxmox 系统盘（**确认磁盘容量，不可选错**）
   - 使用整盘（Use entire disk）

#### 2.3.3 在 VM 中安装 Proxmox 到物理盘

1. 启动 VM，进入 Proxmox 安装器（TUI 文本界面）
2. 键盘输入：
   - **Moonlight 客户端**提供完整键盘直通（推荐）
   - 或使用 Windows 屏幕键盘 `Win+R → osk` 鼠标点击输入
3. 按常规流程安装：
   - 选择目标磁盘（即直通的物理盘）
   - 文件系统选 **ext4**（默认 LVM-thin 布局）
   - 设置 root 密码、邮箱
   - 网络先设 DHCP（装完后续统一改静态 IP）
   - 安装 GRUB 到目标磁盘（`/dev/sda` 或 `/dev/nvme0n1`）

#### 2.3.4 切换到 Proxmox 引导

1. VM 安装完成后关机
2. 物理机重启，进 BIOS 将新装的 Proxmox 盘设为第一启动项
3. 启动后 Proxmox 将进入宿主机控制台界面
4. 从另一台机器 SSH 登录随即接管：
   ```bash
   ssh root@<Proxmox DHCP IP>
   ```
5. 浏览器访问 `https://<IP>:8006`，后续所有配置均远程完成。

> **优势**：全程无需接物理键盘，Windows + Moonlight 提供完整键鼠控制，物理盘直通确保 GRUB 正确写入，装完即可物理引导。

---

## 3. GPU 直通配置

### 3.1 启用 IOMMU
编辑 `/etc/default/grub`，添加对应参数：
- Intel：`intel_iommu=on iommu=pt`
- AMD：`amd_iommu=on iommu=pt`

示例：
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"
```
更新 GRUB：
```bash
update-grub
```

### 3.2 加载 VFIO 模块
编辑 `/etc/modules`，添加：
```
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
```
执行：
```bash
update-initramfs -u -k all
reboot
```

### 3.3 隔离直通显卡
获取 GPU 及音频设备的 PCI ID：
```bash
lspci -nn | grep -i nvidia
```
示例输出：
```
01:00.0 VGA compatible controller [0300]: NVIDIA ... [10de:2788]
01:00.1 Audio device [0403]: NVIDIA ... [10de:22b1]
```
创建 `/etc/modprobe.d/vfio.conf`：
```
options vfio-pci ids=10de:2788,10de:22b1 disable_vga=1
```
重新生成 initramfs 并重启：
```bash
update-initramfs -u
reboot
```

### 3.4 验证接管
```bash
lspci -nnk -d 10de:2788
```
驱动应为 `vfio-pci`。

---

## 4. Windows 物理盘直通实现双启动

这是本方案的核心亮点：Windows 独占一块物理硬盘，既可以由主板 UEFI 直接引导（原生），也可以被 Proxmox 以整盘方式直通给虚拟机启动。两种方式使用**完全相同的系统和数据**。

### 4.1 准备工作：清理目标硬盘并获取磁盘 ID
确定分配给 Windows 的物理硬盘，例如 `/dev/nvme1n1`。使用 `lsblk` 确认容量，然后获取其 **by-id** 唯一标识符：
```bash
ls -la /dev/disk/by-id/
```
你会看到类似 `nvme-Samsung_SSD_990_PRO_<序列号>` 或 `ata-Samsung_SSD_xxx` 的软链接。记下此 ID，后续直通均使用 `/dev/disk/by-id/xxx` 以避免设备名漂移。

### 4.2 直接从此物理盘安装 Windows（裸机安装）
**强烈建议先在裸机环境下安装 Windows，以确保双系统原生的引导兼容性。**
1. 关机，仅连接目标硬盘和 Windows 安装 U 盘（拔掉 Proxmox 系统盘以避免误操作）。
2. 使用官方 Windows 安装介质引导，在目标硬盘上完成系统安装。安装过程中确保采用 **UEFI + GPT** 模式。
3. 安装完成后，进入 Windows，提前安装：
   - **VirtIO 驱动**（网卡、SCSI、Balloon 等）：从 [这里](https://pve.proxmox.com/wiki/Windows_VirtIO_Drivers) 下载 ISO 并挂载，手动安装 `vioscsi`、`NetKVM` 等驱动。
   - **NVIDIA 显卡驱动**（如果后续需要 GPU 直通）。
4. 关机，重新插回 Proxmox 系统盘，进入 BIOS 设置 Proxmox 盘为第一启动项。

> **为什么先裸机安装？**  
> 这样可以确保 Windows 引导加载程序正确写入该硬盘的 EFI 分区，方便后续物理启动。若反过来先在虚拟机中安装，可能缺少裸机必要的驱动，但也能通过修复引导解决。我们之后会说明如何在虚拟机中修复。

### 4.3 创建“直通整盘”的 Windows 虚拟机
在 Proxmox Web GUI 中：

**Create VM**，常规选项卡设置：
- **ID**：自定义，例如 `100`。
- **Name**：`Windows-Dual`
- **OS**：**不使用任何介质**，`Guest OS` 选 `Microsoft Windows 11/2022`。
- **System**：BIOS 必须选 **OVMF (UEFI)**，添加 **EFI Storage**（放在 `local-lvm` 上，这只是个虚拟的 UEFI 变量存储，很小），添加 **TPM v2.0**（Win11 需要）。
- **Disk**：**不要创建系统盘**，将 `Bus/Device` 设为 `无`。
- **CPU**：4-8 核，`Type = host`。
- **Memory**：16 GB 起，关闭 Ballooning。
- **Network**：VirtIO (半虚拟化)，模型选 `VirtIO`。

**在 `Hardware` 中添加物理磁盘：**
1. 点击 `Add` → `Hard Disk`。
2. 在 `Bus/Device` 选择 **SATA**（更兼容直通整盘）或 **VirtIO Block**（性能更好，但需确保 Windows 已安装 VirtIO 驱动）。
   - 推荐首次配置时使用 **SATA**，待进入系统安装完 VirtIO 驱动后可改为 VirtIO 以提高性能。
3. `Disk/Image` 下拉选择 `lun`，然后在 `Path` 中输入 `/dev/disk/by-id/你的Windows硬盘ID`。
4. **不要**勾选 `Discard` 或 `Backup`（整盘直通无法被 PVE 备份）。
5. 确认后，虚拟机会将此物理硬盘作为唯一系统盘。

**添加 PCI 设备（直通 GPU）：**
- `Add` → `PCI Device`，选择之前已隔离的 NVIDIA GPU 及其 Audio 设备。
- 勾选 `All Functions`、`Primary GPU`、`ROM-Bar`、`PCI-Express`。

**调整引导顺序：**
进入 VM 的 `Options` → `Boot Order`，确保物理硬盘在首位，并启用 UEFI 引导。

### 4.4 首次虚拟机启动与驱动完善
启动虚拟机，如果之前裸机安装正确，Windows 应能直接引导进入系统。
- 进入系统后，设备管理器中可能还有未识别设备，挂载 VirtIO 驱动 ISO 进行补全。
- 若希望磁盘性能更高，可在安装完 `vioscsi` 驱动后**关闭虚拟机**，将物理硬盘的连接方式从 **SATA** 改为 **VirtIO Block**，再启动即可无缝切换。

如果 Windows 无法引导（蓝屏 INACCESSIBLE_BOOT_DEVICE），通常是缺少 VirtIO 存储驱动所致。临时将硬盘连接方式改为 SATA 启动，安装驱动后再改回 VirtIO。

### 4.5 双系统引导设置：物理启动 vs 虚拟机启动
完成后，你拥有两种启动方式：
- **物理启动**：开机按 BIOS 引导菜单，选择 Windows 硬盘直接启动，获得原生裸机性能。
- **虚拟机启动**：进入 Proxmox 宿主机系统后，从 Web GUI 启动此 VM，配合 GPU 直通、Sunshine 等使用 Windows。

> **说明**：由于两者共用同一份 Windows，系统内安装的软件、游戏进度、配置完全一致，这也是本方案的核心优势。需注意 Windows 可能会因硬件环境变化（物理机 vs VM）激活状态丢失，使用微软账户绑定的数字许可证可方便解决。

---

## 5. Sunshine / Moonlight 游戏串流

### 5.1 在 Windows 虚拟机内安装 Sunshine
- 下载 Sunshine：[https://github.com/LizardByte/Sunshine/releases](https://github.com/LizardByte/Sunshine/releases)
- 安装为服务并设置 Web UI 用户名/密码。
- 在 `https://localhost:47990` 配置：
  - 编码器选择 `NVIDIA NVENC`。
  - **应用锁定模式**：可添加《绝区零》等游戏，让串流独立于桌面操作。

### 5.2 客户端连接
- 在其他设备安装 Moonlight 客户端。
- 使用局域网 IP 配对（在 Sunshine Web UI 中输入 PIN 确认）。

### 5.3 Headless 运行 Windows
虚拟机无需接显示器显卡，通过 Moonlight 即可完全操控。在 Windows 电源选项中设置**关闭显示器 → 从不**，**睡眠 → 从不**。

---

## 6. 部署 AI 智能体（OpenCode / Hermes）与宿主机运维

### 6.1 部署方式选择
综合你之前的讨论，我们采用 **LXC 容器** 部署 Hermes/OpenCode，并通过 **MCP (Model Context Protocol)** 连接 Proxmox API，实现 AI 对宿主机的智能维护。

| 部署方式 | 适用场景 |
|----------|----------|
| **Ubuntu LXC 容器** | 资源隔离、轻量、易迁移。部署 AI Agent 的理想选择。 |
| **专用 VM** | 需要 GPU 直通做本地模型推理时选（但我们这里 Agent 只做管理，无需 GPU）。 |
| **宿主机直接安装** | 不推荐，避免污染 PVE 环境。 |

### 6.2 创建 Ubuntu LXC 容器
```bash
pct create 200 local:vztmpl/ubuntu-24.04-standard_24.04-1_amd64.tar.zst \
    --ostype ubuntu --hostname ai-agent --memory 4096 --cores 4 \
    --net0 name=eth0,bridge=vmbr0,ip=dhcp --storage local-lvm --rootfs 30G
pct start 200
pct enter 200
```

### 6.3 在 LXC 容器内安装 Hermes Agent
```bash
apt update && apt install -y curl ca-certificates
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
```
根据提示配置大模型后端（如 DeepSeek、OpenAI 等）。Hermes 原生支持 MCP，非常适合集成外部工具。

### 6.4 安装 OpenCode（并行 AI 编码助手，可选）
```bash
curl -fsSL https://opencode.ai/install | bash
```
启动：
```bash
opencode serve &   # 后台 API
opencode web --hostname 0.0.0.0 --port 4096 --password 你的密码
```

### 6.5 赋予智能体运维能力：MCP 集成 Proxmox
AI Agent 要管理宿主机，我们需要为它提供可供调用的 MCP 服务器，推荐使用社区现成的 `proxmox-mcp` 方案。

#### 6.5.1 创建最小权限的 API Token
在 Proxmox Web GUI：
- **Datacenter → Permissions → API Tokens → Add**
- 选择用户 `root@pam`（或新建一个专用于 Agent 的管理员用户）。
- Token 名称例如 `hermes-mcp`。
- 权限建议先设为只读的 `PVEAuditor` 角色（安全起见），确认需求后逐步开放 `PVEVMAdmin` 等操作权限。
- 记下 **Token ID** 和 **Secret**。

#### 6.5.2 部署 proxmox-mcp 服务
在容器内通过简单 Python 环境运行：
```bash
apt install -y python3-pip git
pip install proxmoxer mcp
git clone https://github.com/your-fork/proxmox-mcp-openapi  # 替换为实际社区仓库
cd proxmox-mcp-openapi
# 配置环境变量
export PROXMOX_HOST="你的PVE_IP"
export PROXMOX_USER="root@pam"
export PROXMOX_TOKEN_NAME="hermes-mcp"
export PROXMOX_TOKEN_VALUE="你的Secret"
python3 server.py   # 默认监听 8080，暴露标准 MCP 接口
```

#### 6.5.3 在 Hermes 中注册该 MCP 工具
Hermes 的配置文件通常在 `~/.hermes/config.yaml` 中，添加工具定义：
```yaml
tools:
  - name: proxmox
    type: mcp
    endpoint: http://127.0.0.1:8080
```
重启 Hermes 后，即可通过自然语言让 Agent 执行监控、创建 VM、清理快照等操作。

### 6.6 实战：AI 维护宿主机场景
- **健康检查**：“帮我检查所有 VM 的 CPU 使用率，并标记出资源紧张的节点。”
- **自动备份**：“每个周日凌晨 3 点，对 VM 100 执行快照备份，保留最近 3 份。”
- **告警联动**：结合 Prometheus + Grafana（可在容器中快速搭建），当 CPU > 90% 时，通过 Hermes 发送 Discord 通知。

**关键实践：**
- 为新任务使用**新会话 ID**，避免上下文污染。
- 敏感操作开启**人工审批**，可借助 MCP 的回调确认机制。
- 建立**冲突锁定**，避免多个 Agent 同时操作同一资源。

### 6.7 可选：可视化边缘编排 n8n
若需要复杂的自动化工作流（如定期备份并发送报告，图形化拖拽设计），可在另一个 LXC 中部署 n8n，它与 Proxmox API 天然契合，并可与 Hermes 联动。

---

## 7. 安全与远程访问

- **避免直接暴露 PVE 端口**：使用 **Tailscale** 构建虚拟局域网。
- **在容器和宿主机安装 Tailscale**：
  ```bash
  curl -fsSL https://tailscale.com/install.sh | bash
  tailscale up
  ```
- 以后只需通过 Tailscale IP 访问 Proxmox Web、OpenCode Web 等。
- SSH 通过 Tailscale 加密隧道。

---

## 8. 最终架构拓扑

```
+-----------------------------------------------+
|           Proxmox VE 宿主机 (Headless)          |
|                                               |
|  +----- 物理盘直通 Windows VM -------+         |
|  |  Windows 10/11 (UEFI)            |         |
|  |  - 直接安装于物理 NVMe           |         |
|  |  - GPU 直通 (NVIDIA)             |         |
|  |  - Sunshine 串流服务             |         |
|  +--+-------------------------------+         |
|     |                                         |
|  +--+---------------------------- LXC 容器    |
|  |  AI-Agent (Ubuntu)             |           |
|  |  - Hermes Agent                |           |
|  |  - OpenCode Web (可选)         |           |
|  |  - MCP Server (管理 PVE)       |           |
|  +--------------------------------+           |
|                                               |
|  +--->  Moonlight 客户端 (笔记本/手机/电视)    |
|  +--->  Web 浏览器访问 OpenCode / Hermes UI   |
+-----------------------------------------------+
         |
         +----> 物理启动: 开机选择 Windows 硬盘原生启动
```

---

## 9. 总结

这套方案将你的多核心需求完美融合：

- **Windows 物理盘直通** 让你既能双系统裸机启动获得满血性能，又能以虚拟机方式运行利用 Proxmox 生态，系统状态完全一致。
- **GPU 直通** 保障了完美游戏体验和 Sunshine 串流。
- **Hermes & OpenCode** 提供 7×24 在线的 AI 编码与辅助能力。
- **宿主机智慧运维** 通过 MCP 让 AI 成为了你的私人虚拟化管家，省心省力。

后续可根据需要扩展：添加 NAS 功能、Home Assistant、AI 模型训练环境等，一切尽在掌控。

---

## 10. 实施进度

### Phase 1 ✅ PVE 安装（2026-04-30 ~ 05-01）

**方式**：Windows → QEMU → 直通物理盘 → kernel/initrd 直接启动 → PVE TUI 安装器

**已完成的配置**：
- [x] PVE 9.1 已安装到 ZHITAI TiPlus7100 2TB 物理盘（GPT + EFI + LVM）
- [x] LVM：pve-root (96G) + pve-swap (8G) + pve-data (thin, 剩余空间)
- [x] 网络：vmbr0 桥接 DHCP，通过 systemd.link 按 MAC 固定网卡名为 lan0
- [x] UEFI GRUB 安装 + 回退引导 (/EFI/BOOT/BOOTX64.EFI)
- [x] SSH 密钥部署完毕，root 密码已知
- [x] PVE Web 面板 (pveproxy) 正常运行

**待完成（物理启动后）**：
- [ ] 物理启动，确认网卡识别为 lan0
- [ ] PVE Web 面板访问（https://<IP>:8006）
- [ ] 配置静态 IP、DNS、NTP
- [ ] 配置 PVE 订阅/仓库
- [ ] 创建 Windows VM + 物理盘直通 + GPU 直通
- [ ] 部署 Sunshine + Moonlight
- [ ] 部署 AI Agent 容器（Hermes / OpenCode）

**物理启动步骤**：
1. 重启电脑
2. BIOS/UEFI 选 ZHITAI TiPlus7100 2TB 启动
3. 启动后检查网络：ip a show vmbr0
4. SSH 接入或直接 Web 访问 PVE
