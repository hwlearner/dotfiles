# Tailscale 直连配置：路由器 UDP 端口转发

## 背景

Mac（中国移动宽带）和家里服务器之间由于**对称 NAT**，Tailscale 无法建立 P2P 直连，所有流量都经过洛杉矶 DERP 中继（延迟 ~350ms）。

**修复方法**：在路由器上做 UDP 端口转发，让 Tailscale 能直接穿透 NAT。

## 配置步骤

### 1. 登录路由器后台

- **路由器 IP**: `192.168.1.1`
- **账号密码**: 在路由器背面标签上

打开浏览器访问 `http://192.168.1.1`

### 2. 找到端口转发设置

不同路由器菜单名称不同，常见的有：

| 品牌 | 菜单路径 |
|------|---------|
| TP-Link | 转发规则 → 虚拟服务器 |
| 小米 | 高级设置 → 端口转发 |
| 华为 | 安全 → 端口映射 |
| 华硕 | 外部网络(WAN) → 端口触发/端口转发 |
| 其他 | 搜索"端口转发"、"虚拟服务器"、"Port Forwarding" |

### 3. 添加规则

| 字段 | 值 |
|------|-----|
| **协议** | UDP |
| **外部端口** | 41641 |
| **内部 IP** | `192.168.1.12`（PVE 宿主机） |
| **内部端口** | 41641 |
| **描述** | Tailscale 直连 |

### 4. 重启 Tailscale

Mac 上执行：

```bash
sudo launchctl kickstart -k system/net.sf.tailscale
```

PVE 宿主机上：

```bash
systemctl restart tailscaled
```

### 5. 验证

在 Mac 上执行：

```bash
tailscale ping --c 5 100.65.103.30
```

- ✅ **成功**: 看到 `pong via IP 192.168.1.12:41641` — 直连延迟 ~5ms
- ❌ **失败**: 看到 `pong via DERP` — 端口转发未生效，检查路由器设置

也可以在 Mac 上检查连接状态：

```bash
tailscale status
```

看到 `active; direct 192.168.1.12:41641` 即为直连成功。
