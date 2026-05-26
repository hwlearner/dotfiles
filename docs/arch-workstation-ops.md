# Arch Linux 工作站运维手册

> 最后更新：2026-05-25 | 主机：Workstation (R9 8745HS + RTX 4080S)

---

## 系统概览

| 项目 | 值 |
|---|---|
| 系统 | Arch Linux, kernel 7.0.x |
| Shell | Zsh 5.9 + Starship |
| 桌面 | Hyprland 0.55.2 + SDDM |
| 终端 | Ghostty |
| 编辑器 | Neovim 0.12.2 |
| 磁盘 | 931G NVMe，已用 35G（4%） |
| 输入法 | fcitx5 + 拼音 |
| 代理 | mihomo（Clash Meta）|
| 容器 | 3 × systemd-nspawn（esl/hish/pi）|

---

## 桌面环境 — Hyprland

### 快捷键

| 快捷键 | 功能 |
|---|---|
| `$mod + Return` | 打开终端 (Ghostty) |
| `$mod + Q` | 关闭窗口 |
| `$mod + D` | 打开启动器 (Walker) |
| `$mod + H/J/K/L` | 移动焦点（vim 风格） |
| `$mod + Shift + H/J/K/L` | 移动窗口 |
| `$mod + 1-9` | 切换到工作区 |
| `$mod + Shift + 1-9` | 窗口移动到工作区 |
| `$mod + F` | 全屏切换 |
| `$mod + Shift + Space` | 切换浮动/平铺 |
| `$mod + R` | 进入 resize 模式（hjkl 调整，ESC 退出） |
| `$mod + V` | 切换 split 方向 |
| `$mod + S` | 切换布局 (dwindle/master) |
| `$mod + Tab` | 循环切换窗口焦点 |
| `$mod + N` | WiFi 管理 (impala-float) |
| `$mod + Ctrl + L` | 锁屏 (hyprlock) |
| `$mod + Shift + C` | 重载配置 |
| `Print` | 截图（区域） |
| `$mod + Print` | 截图（当前窗口） |
| `$mod + Shift + Print` | 截图（全屏） |
| `XF86Audio*` | 音量控制 (pipewire) |
| `XF86MonBrightness*` | 亮度控制 |

### 自动启动

配置在 `~/.config/hypr/hyprland.lua` → `hl.on("hyprland.start", ...)`，按顺序：

```
hyprpaper          → 壁纸引擎
darkman            → 暗色模式切换
wallpaper-random   → 随机壁纸
elephant           → Walker 数据源
walker             → 启动器服务
sunshine           → 游戏串流
mako               → 通知
fcitx5             → 输入法
swayosd-server     → 音量/亮度 OSD
hyprpolkitagent    → 权限认证
hypridle           → 空闲锁屏
cliphist           → 剪贴板历史
```

### 重载配置

```
hyprctl reload         # 快捷键: $mod + Shift + C
```

`hl.on("hyprland.start", ...)` 只在重新登录时触发，`reload` 不会重跑自动启动。

---

## 启动器（Walker）

| 操作 | 用法 |
|---|---|
| 应用启动 | 直接打字 |
| 计算器 | 直接输 `1+2*3` |
| Web 搜索 | 直接输关键词 + 回车 |
| 文件搜索 | `/文件名` |
| 剪贴板历史 | `:` 前缀 |
| 符号/表情 | `.` 前缀（`.fire` → 🔥） |
| 待办事项 | `!` 前缀 |
| 命令执行 | `>` 前缀 |
| 窗口切换 | `$` 前缀 |
| 书签 | `%` 前缀 |

---

## 壁纸

| 项目 | 值 |
|---|---|
| 引擎 | hyprpaper |
| 图库 | `~/Pictures/macOS-Wallpapers/`（39 张 macOS 壁纸） |
| 脚本 | `~/.local/bin/wallpaper-random.sh` |
| 缓存 | `~/.cache/wallpaper-current` |

手动换壁纸：`~/.local/bin/wallpaper-random.sh`

---

## 字体

| 用途 | 字体 |
|---|---|
| 终端（主力） | Maple Mono NL NF CN |
| CJK 回退 | Noto Sans Mono CJK SC |
| Emoji 回退 | Noto Color Emoji |

fontconfig 配置：`~/.config/fontconfig/conf.d/99-nerd-cjk-emoji-fallback.conf`

---

## 网络与代理

### mihomo 代理

- 服务：`mihomo.service`（系统服务，自启）
- HTTP/Socks: `127.0.0.1:7890`
- TProxy: `0.0.0.0:7891`
- 管理面板: `127.0.0.1:9090`
- 配置：`~/Projects/dotfiles/arch/mihomo.yaml`
- 检测到代理运行时，zshrc 自动设置 `HTTP_PROXY`/`HTTPS_PROXY`

## 开发容器（systemd-nspawn）

主机名 `MiniHan`，用 **systemd-nspawn** 运行 3 个轻量容器，共享宿主内核，启动极快。

### 容器总览

| 名称 | IP | 工作目录 | 用途 |
|---|---|---|---|
| **esl** | 10.0.0.100 | `/workspace` → `~/Projects/ESL_SIMULATOR` | 主项目开发 |
| **hish** | 10.0.0.101 | `/workspace` → `~/Projects/HiSH` | 另一个项目开发 |
| **pi** | 10.0.0.102 | `/workspace` → `~/Projects/pi` | Oh My Pi agent 服务 |

### 网络拓扑

```
宿主 MiniHan
  └── br-nspawn (10.0.0.1/24)
        ├── esl   (10.0.0.100)  ← DHCP 静态绑定
        ├── hish  (10.0.0.101)  ← DHCP 静态绑定
        └── pi    (10.0.0.102)  ← DHCP 静态绑定
```

- 网桥 `br-nspawn` 由 systemd-networkd 管理
- 容器通过网桥访问外网（IPMasquerade）
- 配置：`/etc/systemd/network/br-nspawn.{netdev,network}`

### 共享挂载

所有容器通过 `.nspawn` 配置的 `Bind` / `BindReadOnly` 共享：

| 容器内路径 | 宿主来源 | 权限 |
|---|---|---|
| `/usr/local/bin` | `~/Tools/bin/`（bun + pi） | 读写 |
| `/workspace` | 各容器独立绑定 | 读写 |
| `/home/han/dotfiles` | `~/Projects/dotfiles` | 只读 |
| `/home/han/.ssh` | `~/.ssh` | 只读 |
| `/home/han/.zshrc` | dotfiles/.zshrc | 只读 |
| `/home/han/.config/nvim` | `~/.config/nvim` | 只读 |
| `/home/han/.config/gh` | `~/.config/gh` | 只读 |
| `/opt/command-line-tools` | `/opt/command-line-tools`（仅 hish） | 只读 |
| `/home/han/.pi/agent/*` | `~/.pi/agent/*`（esl/hish） | 只读 |

### 远程运维接口

用于 Oh My Pi agent 和 SSH 自动化。脚本位于 `~/Projects/dotfiles/arch/`，安装至 `/usr/local/bin/`：

| 脚本 | 功能 |
|---|---|
| `arch-agent-dev` | 工作区 Git 操作（ws-list, ws-status, git-log, git-pull） |
| `arch-agent-podman` | Podman 容器操作（当前未用） |
| `arch-agent-service` | systemd 服务管理（start/stop/restart/status/enable/disable） |
| `arch-agent-status` | 系统状态 JSON 报告（CPU/内存/磁盘/负载） |

**SSH 受限 Shell**：`arch/devops-shell`

限制远程 SSH key 只能执行以上脚本，禁止任意 shell：

```
# ~/.ssh/authorized_keys 中对应 key 的开头加上：
command="/usr/local/bin/devops-shell",restrict ssh-ed25519 ...
```

### 容器启动配置

每个容器对应 `/etc/systemd/nspawn/<name>.nspawn`：

```ini
[Exec]
Boot=on                    # 容器自启
PrivateUsers=no            # 与宿主共享 UID 映射

[Network]
Bridge=br-nspawn           # 接网桥

[Files]
BindReadOnly=/usr          # 共享只读 usr（节省空间）
Bind=...                   # 工作区绑定
BindReadOnly=...           # dotfiles 等共享
```

### 进入容器

```bash
# 方式一：machinectl（推荐）
machinectl shell esl
machinectl shell hish
machinectl shell pi

# 方式二：login prompt
machinectl login esl

# 查看状态
machinectl status esl
machinectl list
systemctl status systemd-nspawn@esl
```

### 容器管理

```bash
# 重启容器
systemctl restart systemd-nspawn@esl

# 停止/启动
systemctl stop systemd-nspawn@esl
systemctl start systemd-nspawn@esl

# 重建容器（重新安装系统）
systemctl stop systemd-nspawn@esl
rm -rf /var/lib/machines/esl
pacstrap -C /etc/pacman-nspawn.conf /var/lib/machines/esl base base-devel zsh openssh
systemctl start systemd-nspawn@esl
machinectl shell esl
# 容器内首次配置
passwd
systemctl enable sshd --now
```

## 开发工具

| 工具 | 版本管理 | 说明 |
|---|---|---|
| Neovim 0.12.2 | pacman | 主力编辑器 + LazyVim |
| Rust | rustup | toolchain via rustup |
| Bun | 独立 `~/.bun` | JS/TS 运行时 |
| Node.js | pacman | 全局安装 |
| Python | pacman | 系统 Python |
| Go | ❌ 已卸载 | 需用时 `pacman -S go` |

shell 补全 / 历史搜索使用 **skim**（可执行文件 `sk`）。

### 目录跳转（zoxide）

```
z foo          → 自动跳转（frecency 排序）
zi             → 交互选择（快捷键 j 同功能）
```

---

## 输入法

- 引擎：fcitx5
- 中文：中州拼音
- 切换：默认中文，`Shift` 切换中/英
- 配置工具：`fcitx5-configtool`
- per-app 输入法状态记忆：可通过 `fcitx5-configtool` 启用

---

## 剪贴板管理

- 服务：`wl-paste --watch cliphist store`（自动监听）
- 配合 Walker：`:` 前缀搜索历史记录
- 数据存储：cliphist 数据库

---

## 截图

| 方式 | 命令/快捷键 |
|---|---|
| 区域截图 | `Print` / `hyprshot -m region` |
| 窗口截图 | `$mod + Print` / `hyprshot -m window` |
| 全屏截图 | `$mod + Shift + Print` / `hyprshot -m output` |

默认保存到 `~/Pictures/Screenshots/`。

---

## 游戏串流（Sunshine）

- Sunshine 驻留后台（自动启动）
- Xbox 手柄直连
- 需要 xdg-desktop-portal-hyprland 提供屏幕捕获

---

## 系统服务一览

### 系统服务（system）

| 服务 | 用途 |
|---|---|
| `mihomo` | 代理网关 |
| `sshd` | SSH 远程登录 |
| `sddm` | 登录管理器 |
| `iwd` | WiFi 管理 |
| `pgyvpn` | VPN 隧道 |
| `herdr-server` | AI agent 服务 |
| `systemd-nspawn@esl/hish/pi` | 3 个 nspawn 容器 |

### 用户服务（systemd --user）

| 服务 | 用途 |
|---|---|
| `darkman` | 暗色/亮色模式自动切换 |
| `pipewire` / `wireplumber` | 音频系统 |
| `gnome-keyring-daemon` | Chromium 密码存储 |
| `xdg-desktop-portal*` | 桌面 Portal 服务 |

---

## 维护清单

### 日常更新

```bash
# 系统更新
sudo pacman -Syu

# AUR 更新
paru -Syu

# 清理旧包缓存（保留最近 3 个版本）
sudo paccache -r

# 清理孤儿包
sudo pacman -Rns $(pacman -Qqdt)

# 重新生成 fontconfig 缓存
fc-cache -fv
```

### dotfiles 同步

```bash
cd ~/Projects/dotfiles
git add -A
git commit -m "update: 变更说明"
git push
```

### 配置文件热重载

| 配置 | 重载方式 |
|---|---|
| Hyprland | `hyprctl reload` 或 `$mod + Shift + C` |
| Zsh | `source ~/.zshrc` 或新开终端 |
| Starship | 立即生效 |
| fcitx5 | `fcitx5-remote -r` 或重启 fcitx5 |
| mihomo | `systemctl restart mihomo` |

### 容器管理

详见「开发容器」章节。常用命令速查：

```bash
# 进入容器
machinectl shell esl

# 重启
systemctl restart systemd-nspawn@esl

# 查看状态
machinectl status esl
machinectl list
```

---

## 排错速查

| 症状 | 检查项 |
|---|---|
| 壁纸空白 | `hyprctl hyprpaper listloaded` / `pgrep hyprpaper` |
| 输入法不切换 | `pgrep fcitx5` / `fcitx5-remote -q` |
| 代理不生效 | `systemctl status mihomo` / `curl --proxy http://127.0.0.1:7890 google.com` |
| 字体方框 | `fc-match "Maple Mono NL NF CN:charset=4e00"` 看回退是否到 SC |
| 截图黑屏 | 检查 xdg-desktop-portal-hyprland 是否运行 |
| 容器 ping 不通 | `systemctl status systemd-networkd` / 检查 nspawn 虚拟网卡 |
