# archan — Windows VM 运维手册

## VM 概况

| 项目 | 值 |
|------|-----|
| VM 名称 | `win11` |
| 宿主机 | archan (Arch Linux, i5-13600KF, 32GB RAM) |
| 操作系统 | Windows 11 IoT Enterprise LTSC 2024 |
| GPU | RTX 4080 SUPER 直通 (vfio-pci) |
| 磁盘 | 500GB raw (`/var/lib/libvirt/images/win11.img`) |
| 网络 | macvtap bridge → enp4s0, 固定 IP **192.168.1.20/24** |
| 串流 | Vibepollo v1.15.5 (ApolloService) + Moonlight |

## 生命周期

```bash
# 启动 VM（hook 自动切换 GPU → 宿主机失去显示输出）
virsh -c qemu:///system start win11

# 关机
virsh -c qemu:///system shutdown win11

# 强制关机
virsh -c qemu:///system destroy win11

# 查看状态
virsh -c qemu:///system dominfo win11
```

VM 启动后从**其他局域网设备**连接（macvtap 限制，宿主机无法直接访问）。

## 访问方式

| 方式 | 地址 | 凭据 |
|------|------|------|
| SSH | `ssh han@192.168.1.20` | 公钥认证 |
| Vibepollo Web UI | `https://192.168.1.20:47990/` | `han` / `CMOSdianlu` |
| Moonlight 串流 | 配对 `192.168.1.20` | 同上 |

## 内核参数

当前生效（`/boot/loader/entries/archan-cachyos.conf`）：

```
intel_iommu=on iommu=pt isolcpus=2-11 nohz_full=2-11 rcu_nocbs=2-11
default_hugepagesz=1G hugepagesz=1G hugepages=16
```

- CPU P-core 2-11 已隔离并 pin 给 VM（12 vCPU 配 12 线程，SMT 双线程共享同个物理核）
- 16GB 1GB 大页内存

## VFIO 配置

```
/etc/modprobe.d/vfio.conf
/etc/mkinitcpio.conf → MODULES=(vfio vfio_iommu_type1 vfio_pci)
```

GPU 与 Audio Controller 绑定 vfio-pci：

- `01:00.0` — NVIDIA AD103 [GeForce RTX 4080 SUPER] (10de:2702)
- `01:00.1` — NVIDIA AD103 High Definition Audio (10de:22bb)

## Hook 脚本

`/etc/libvirt/hooks/qemu` — 自动切换 GPU：

| 事件 | 动作 |
|------|------|
| `prepare/begin` | 停 SDDM → 卸载 nvidia 模块 → 绑定 vfio-pci → 启动 VM |
| `release/end` | 解绑 vfio-pci → 加载 nvidia 模块 → 启动 SDDM |

## 工作流程

```
1. SSH 登录宿主机 archan (192.168.1.10)
2. virsh start win11 → hook 自动处理 GPU 切换，宿主机黑屏
3. 从另一台设备 Moonlight/浏览器连接 VM
4. Windows 内关机 → hook 自动恢复宿主机桌面
```

## 注意事项

- **macvtap bridge 模式**：宿主机与 VM 同网段但不互通，需从其他设备管理
- **单卡直通副作用**：VM 启动后宿主机无显示输出（SDDM 被 hook 停掉），只能 SSH 管理
- **NVIDIA 驱动**：GPU 直通后需在 VM 内安装 NVIDIA 官方驱动，否则无硬件加速和 NVENC
- **磁盘**：500GB raw，btrfs nodatacow（路径已 `chattr +C`）
- **Windows LTSC**：评估版 90 天，可 rearm 3 次
- **SSH**：宿主机 SSH 不依赖显示管理器，关机前确保 SSH 会话正常退出

## 常用管理命令

```bash
# VM XML
virsh -c qemu:///system dumpxml win11
virsh -c qemu:///system edit win11

# 磁盘性能
virsh -c qemu:///system domstats win11 --block

# 网络流量
sudo ip -s link show macvtap0

# 大页内存状态
cat /proc/meminfo | grep HugePages_

# GPU 绑定状态
lspci -k -s 01:00
```

```powershell
# Windows VM 内
Restart-Service ApolloService               # 重启 Vibepollo
Get-Service ApolloService                    # 检查服务状态
& "C:\Program Files\Apollo\sunshine.exe"     # 管理工具
```
