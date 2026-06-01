# dotfiles

我的开发环境配置，使用 **GNU Stow** 管理多台机器间的配置同步。

## 目录结构

所有配置按 Stow 包组织，每个包镜像 `$HOME` 路径结构：

```
dotfiles/
├── shell/                  # ~/.zshrc, .zprofile, .zshenv, .gitconfig
├── ghostty/                # ~/.config/ghostty/config
├── yazi/                   # ~/.config/yazi/
├── nvim/                   # ~/.config/nvim/
├── starship/               # ~/.config/starship.toml
├── hypr/                   # ~/.config/hypr/hyprland.lua
├── noctalia/               # ~/.config/noctalia/
├── fcitx5/                 # ~/.config/fcitx5/
├── gtk/                    # ~/.config/gtk-3.0, gtk-4.0
├── fontconfig/             # ~/.config/fontconfig/fonts.conf
├── arch/                   # 运维脚本（非 stow）
├── docs/                   # 运维手册
├── pi/                     # OMP agent 配置
└── feishu-bridge.ts        # 飞书桥接脚本
```

## 使用方式

### 首次部署

```bash
cd ~/Projects/dotfiles
stow -t ~ shell ghostty yazi nvim starship hypr noctalia fcitx5 gtk fontconfig
```

### 在新机器上部署

```bash
git clone git@github.com:hwlearner/dotfiles.git ~/Projects/dotfiles
cd ~/Projects/dotfiles
stow -t ~ shell ghostty yazi nvim starship
# 按需 stow hypr noctalia fcitx5 gtk fontconfig
```

### 卸载某个包

```bash
stow -D -t ~ ghostty
```

## 配置分层

- 公共配置放在 stow 包内版本控制。
- 本机私有配置放在 home 目录的 local 文件里，不提交：
  - `~/.zshenv.local`
  - `~/.zprofile.local`
  - `~/.zshrc.local`
  - `~/.gitconfig.local`

## 主机

| 主机 | 系统 | 角色 |
|------|------|------|
| MiniHan | Arch Linux | 主力工作站、开发容器宿主 |
| WinHan | Windows 11 | IM 智能体主控、游戏/串流 |
| ThinkHan | （待确认） | |
