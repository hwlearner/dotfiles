# archan 交接文档

最后更新：2026-05-17

## 主机概览

- 主机名：`archan`
- 系统：Arch Linux
- 默认运行内核：`linux-cachyos`
- LAN IP：`192.168.1.10`
- SSH：Mac 已配置别名 `archan`，可直接执行 `ssh archan`
- 默认运维用户：`han`
- `han` 已配置免密 sudo
- Tailscale：已登录，当前记录 IP 为 `100.70.209.103`
- Secure Boot：已启用并可正常启动
- 默认启动项：`archan`

## 磁盘与挂载

### 系统盘

- 设备：`/dev/nvme0n1`
- 容量：4TB
- 文件系统：btrfs
- 用途：Arch 系统盘、用户 home、开发工作区、游戏环境

主要挂载：

- `/`
- `/home`
- `/var/log`
- `/var/cache`
- `/boot`

### NAS 盘

- 设备：`/dev/nvme1n1p1`
- 容量：2TB
- 文件系统：ext4
- 标签：`NAS`
- UUID：`43927c66-ae25-4114-93b3-563374eb940f`
- 挂载点：`/srv/nas`
- fstab：`UUID=43927c66-ae25-4114-93b3-563374eb940f /srv/nas ext4 defaults,noatime 0 2`

说明：`/srv/nas` 已开始承载 NAS 共享和 PikPak 下载内容，不再是空盘。

## NAS 服务

Samba 已启用并监听标准 SMB 端口。

访问地址：

```text
smb://192.168.1.10/nas
```

当前共享配置：

- 共享名：`nas`
- 路径：`/srv/nas`
- guest：允许
- 只读：否
- 密码：不需要，guest 访问

相关服务：

```bash
systemctl status smb nmb
```

## 自动解压

自动解压服务已部署并启用。

- 服务名：`auto-extract.service`
- 脚本：`/usr/local/bin/auto-extract`
- 文件名清理脚本：`/usr/local/bin/clean-names.py`
- 监听目录：`/srv/nas`
- 日志：`/var/log/auto-extract.log`

查看状态：

```bash
systemctl status auto-extract
journalctl -u auto-extract -n 100 --no-pager
```

## PikPak 到 NAS 下载

已部署基于 `rclone` 的 PikPak 拉取任务。

- rclone 配置：`/etc/rclone/rclone.conf`
- 任务环境文件：`/etc/default/rclone-pikpak`
- 同步脚本：`/usr/local/bin/rclone-pikpak-sync.sh`
- systemd 服务：`/etc/systemd/system/rclone-pikpak-sync.service`
- systemd 定时器：`/etc/systemd/system/rclone-pikpak-sync.timer`

当前同步策略：

- 定时任务仍保留：`rclone-pikpak-sync.timer`
- 顶层预览图已按“每个目录只抓第一张图”做过一轮
- 当前 `pikpak` 根下保留的顶层图片，表示“尚未补齐完整目录”的候选项

当前一次性补齐任务：

- 目录匹配清单：`/tmp/pikpak_vip_matches_fresh.txt`
- 续传脚本：`/tmp/pikpak_sync_vip_fresh.sh`
- 日志：`/tmp/pikpak_sync_vip_fresh.log`
- 行为：根据 `pikpak` 根下剩余预览图，去 `pikpak:Pack From Shared/【VIP】资源打包` 中匹配同名目录，并把完整目录直接下到 `/srv/nas/pikpak/<目录名>`
- 当前采用低并发：`--transfers 1 --checkers 2`

已知现象：

- PikPak / rclone 偶发会卡在单个大视频或报 `unexpected EOF`
- 之前清理过 `.partial` 和 `._*` 残留文件
- 已下好的目录，其对应顶层预览图可以继续定期清理

查看状态：

```bash
systemctl status rclone-pikpak-sync.service --no-pager
systemctl status rclone-pikpak-sync.timer --no-pager
pgrep -af 'pikpak_sync_vip_fresh|rclone copy'
tail -50 /tmp/pikpak_sync_vip_fresh.log
du -sh /srv/nas/pikpak
```

## Mihomo 透明代理

宿主机已部署 Mihomo，当前承担两类用途：

- 局域网透明代理网关
- 给开发容器 `esl` 提供固定 TCP 出站代理

关键文件：

- 二进制：`/usr/local/bin/mihomo`
- 主配置：`/etc/mihomo/config.yaml`
- GeoIP：`/etc/mihomo/Country.mmdb`
- GeoSite：`/etc/mihomo/GeoSite.dat`
- 网关规则脚本：`/usr/local/sbin/mihomo-gateway-rules.sh`
- `esl` 开发容器规则脚本：`/usr/local/sbin/mihomo-dev-esl-rules.sh`

相关服务：

- `mihomo.service`
- `mihomo-gateway.service`

当前端口：

- `7890` mixed
- `7891` tproxy
- `7892` redir（给开发容器用）
- `5353` DNS
- `9090` controller（当前仅绑定 `127.0.0.1`）

查看状态：

```bash
systemctl status mihomo mihomo-gateway
ss -ltnup | grep -E ':(7890|7891|7892|5353|9090)'
curl -fsS -H 'Authorization: Bearer CMOSdianlu' http://127.0.0.1:9090/version
```

## 开发环境

开发环境使用 rootless Podman。

### ESL 容器

- 容器名：`esl`
- 运行用户：`han` 的 rootless Podman
- 宿主机代码路径：`/home/han/Projects/ESL_SIMULATOR`
- 容器内代码路径：`/workspace/ESL_SIMULATOR`
- 容器镜像：`localhost/esl-dev:esl-current`
- 网络模式：`bridge`
- 当前容器 IP：`10.88.0.5`（桥接地址，后续可能变化）
- 自启动服务：`esl-podman.service`，属于 `han` 用户级 systemd
- 代理 drop-in：`/home/han/.config/systemd/user/esl-podman.service.d/mihomo-dev-proxy.conf`

进入容器：

```bash
podman exec -it esl bash
cd /workspace/ESL_SIMULATOR
```

查看状态：

```bash
podman ps
systemctl --user status esl-podman.service
podman inspect esl --format 'Mode={{.HostConfig.NetworkMode}} IP={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} Image={{.ImageName}}'
```

已确认容器内工具链：

- CMake 3.28.3
- Clang 18.1.3
- Ninja
- GDB
- Valgrind
- ripgrep

当前代理/GPU 状态：

- 没有给容器注入 `HTTP_PROXY`、`HTTPS_PROXY`、`ALL_PROXY` 这类环境变量
- 容器 TCP 出站通过宿主机 `iptables + cgroup` 规则重定向到 Mihomo `redir-port 7892`
- DNS 仍走容器自身 `resolv.conf`
- 当前没有把宿主机 NVIDIA GPU 映射进容器，`esl` 现在不能直接使用宿主机的 `4080 SUPER`

### Dotfiles / Codex / cc-connect

容器内当前已整理为两层边界：

- 共享静态配置：通过宿主机 bind mount 的 `/home/han/.local/share/dotfiles-host` 提供
- 容器运行态配置：保留在容器自己的 `~/.config/*`

当前已软链到宿主机 dotfiles 挂载源的项目：

- `~/.zshrc`
- `~/.zprofile`
- `~/.zshenv`
- `~/.gitconfig`
- `~/.tmux.conf`
- `~/.config/git/ignore`
- `~/.config/nvim`
- `~/.config/ghostty/config`

### 容器运行环境（OMP + 飞书桥接）

容器内当前已整理为两层边界：

- 共享静态配置：通过宿主机 bind mount 的 `/home/han/.local/share/dotfiles-host` 提供
- 容器运行态配置：保留在容器自己的 `~/.config/*`

当前已软链到宿主机 dotfiles 挂载源的项目：

- `~/.zshrc`
- `~/.zprofile`
- `~/.zshenv`
- `~/.gitconfig`
- `~/.tmux.conf`
- `~/.config/git/ignore`
- `~/.config/nvim`
- `~/.config/ghostty/config`

当前容器内 `ls` 已通过 `eza` 生效，默认 shell 为 zsh。

#### 运行时

已移除所有 Node.js / npm 依赖，改用 **Bun** 作为唯一运行时：

- Bun v1.3.14
- 全局二进制目录：`~/.bun/bin/`
- PATH 需包含 `$HOME/.bun/bin`

已安装的关键 CLI：

- **OMP** (`@oh-my-pi/pi-coding-agent` v15.1.3)：编程助手入口，提供 `omp launch` / `omp --print`
- **Lark CLI** (`@larksuite/cli` v1.0.32)：飞书 API 命令行工具，用于收发消息
- **OMP Plugin Manager** (`@oh-my-pi/cli` v1.3.37)
- **eza** (v0.23.4)：现代 `ls` 替代（原生 Rust 二进制）

已彻底移除：Codex、cc-connect、opencode-ai、Claude Code、Node.js/npm/npx

#### 飞书桥接（feishu-bridge）

桥接脚本：`/home/han/feishu-bridge.ts`（Bun/TypeScript）

功能：轮询飞书 P2P 聊天的新消息 → 转发 OMP 处理 → 卡片回复

运行方式：tmux 会话 `feishu-bridge`，保活：

```bash
tmux attach -t feishu-bridge              # 查看日志
tail -f /home/han/feishu-bridge.log
```

注意：容器 `/tmp` 有权限问题，临时文件需用 `$HOME/tmp`（已自动处理）

### ESL Web Host

不再通过容器端口转发提供 SimTop 页面。

当前改为宿主机直接 host：

- API 服务：`esl-api.service`
- BrowserSync：`esl-browser-sync.service`
- 页面入口：`http://192.168.1.10:3000/`
- BrowserSync UI：已关闭，不再暴露 `3001`
- `server.py` 仅监听：`127.0.0.1:8765`

查看状态：

```bash
systemctl --user status esl-api.service
systemctl --user status esl-browser-sync.service
curl http://127.0.0.1:3000/ | head
curl http://127.0.0.1:8765/api/docs
```

## 图形与游戏环境

已安装：

- KDE Plasma / SDDM
- NVIDIA open driver
- Steam
- Wine
- Winetricks
- GameMode
- MangoHud
- Gamescope
- umu-launcher

相关服务：

```bash
systemctl status sddm
```

NVIDIA 检查：

```bash
nvidia-smi
```

## Sunshine / Moonlight 串流

Sunshine 已安装官方 Arch 包：

- 版本：`2026.508.45922`
- 包发布方：LizardByte
- 用户级 systemd 服务：`app-dev.lizardbyte.app.Sunshine.service`
- 别名：`sunshine.service`
- `han` 已加入 `video` / `input` 组，满足 Sunshine 访问显卡和输入设备的前置权限
- SDDM 已配置自动登录 `han`
- 当前自动登录会话：`plasma.desktop`（Plasma Wayland）

服务已 enable，目标是随 `han` 的图形会话启动。

当前说明：

- 现在开机后会自动进入 `han` 的 KDE 图形会话，Sunshine 会随会话自动拉起
- 当前本机 Web UI：`https://127.0.0.1:47990`
- 当前局域网可直接访问：`https://192.168.1.10:47990`
- 当前监听端口：`47984`、`47989`、`47990`、`48010`

查看状态：

```bash
systemctl --user status app-dev.lizardbyte.app.Sunshine.service
ss -ltnup | grep -E ':(47984|47989|47990|48010)'
```

手动启动：

```bash
systemctl --user start app-dev.lizardbyte.app.Sunshine.service
```

## 显示器 / EDID 状态

当前 HDMI 欺骗器识别名：`IDV1280X800`。

EDID 解码结果显示它声明支持：

- `1920x1080 120Hz`
- `1920x1080 100Hz`
- `1920x1080 60Hz`
- `10bit`，即 `DC_30bit`
- HDR Static Metadata / ST2084
- `3840x2160 60Hz`
- `2560x1440 144Hz`

但当前 DRM 实际暴露的 mode 只有低分辨率，最高只到 `1280x800`。

后续处理顺序建议：

1. 本地登录 KDE 后用 `kscreen-doctor -o` 再确认一次。
2. 如果 KDE 仍看不到 `1080p120`，再做 EDID override。
3. 不建议优先用虚拟显示器替代 dummy plug，除非 EDID override 仍失败。

## 系统现状补充

- 当前默认运行内核：`linux-cachyos`
- 当前实际运行版本曾确认为：`7.0.5-2-cachyos`
- 官方 Arch `linux` 与 `linux-headers` 已安装，但当前不作为默认运行内核
- 2026-05-16 已执行一轮系统更新，包含 `git`、`neovim`、`ghostty`、`tailscale`、`zsh` 等
- 更新时已补装 `linux-headers` 并执行过 `dkms autoinstall`

## 常用检查命令

```bash
# 网络
ip addr
systemctl status NetworkManager tailscaled sshd

# NAS
findmnt /srv/nas
df -h /srv/nas
systemctl status smb nmb auto-extract
systemctl status rclone-pikpak-sync.service --no-pager
systemctl status rclone-pikpak-sync.timer --no-pager
pgrep -af 'pikpak_sync_vip_fresh|rclone copy'
tail -50 /tmp/pikpak_sync_vip_fresh.log

# 开发容器
podman ps
podman exec -it esl bash
podman inspect esl --format 'Mode={{.HostConfig.NetworkMode}} IP={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} Image={{.ImageName}}'
systemctl --user status esl-api.service
systemctl --user status esl-browser-sync.service
tmux ls                                                    # feishu-bridge 桥接
tail -3 /home/han/feishu-bridge.log                        # 桥接日志

# Mihomo
systemctl status mihomo mihomo-gateway
ss -ltnup | grep -E ':(7890|7891|7892|5353|9090)'
curl -fsS -H 'Authorization: Bearer CMOSdianlu' http://127.0.0.1:9090/version

# 游戏/图形
systemctl status sddm
nvidia-smi
systemctl --user status app-dev.lizardbyte.app.Sunshine.service
```

## 后续建议

- 登录 KDE 后完成 Sunshine Web UI 配置和 Moonlight 配对。
- 处理 HDMI dummy plug 的 mode 暴露问题，目标优先设为 `1080p120 10bit`。
- 如果 NAS 后续需要快照、防误删或透明压缩，可以再考虑从 ext4 迁移到 btrfs；当前 ext4 更简单稳定。
- 如果后续希望 `esl` 保持 rootless 且直接使用宿主机 `4080 SUPER`，优先走 `NVIDIA CDI`，不要先退回 rootful 作为默认方案。
'''
Path('/home/han/Documents/archan-ops-handbook.md').write_text(base64.b64decode(b64).decode())
PY","yield_time_ms":1000,"max_output_tokens":12000} Need use ssh with cat stdin simpler not python b64 in remote. Maybe use local exec_command cp with ssh and cat using stdin redirection. Create local file already. Use commentary exec_command cmd `ssh han@... 'cat > /home/han/Documents/archan-ops-handbook.md' < /Users/han/Projects/dotfiles/archan-ops-handbook.updated.md` and then `ssh ... 'sed -n "1,40p" ...'`. Do that.
