# dotfiles

我的开发环境配置（Arch Linux + Hyprland）。

## 目录结构

- `.zshrc`、`.zprofile`、`.zshenv`、`.gitconfig`：Shell 和 Git 的基础配置。
- `.markdownlint.yaml`：共享的 markdownlint 规则。
- `nvim/`：来自 `~/.config/nvim` 的 Neovim 配置。
- `ghostty/`：来自 `~/.config/ghostty` 的 Ghostty 配置。
- `git/ignore`：来自 `~/.config/git/ignore` 的全局 Git 忽略规则。
- `arch/`：Linux 运维脚本（agent 接口、devops-shell 等）。
- `starship.toml`：Starship prompt 配置。
- `yazi/`：Yazi 文件管理器配置。
- `zellij/`：Zellij 终端复用器配置。

## 配置分层

- 公共配置直接放在仓库根目录。
- 本机私有配置放在 home 目录的 local 文件里，不提交到仓库：
  - `~/.zshenv.local`
  - `~/.zprofile.local`
  - `~/.zshrc.local`
  - `~/.gitconfig.local`
- `.gitconfig` 只保留用户身份和 local include。
  `safe.directory`、credential helper 等机器相关配置放入 `~/.gitconfig.local`。

## 工具来源

开发工具按职责划分来源：

- **系统包管理器**（pacman/paru）：用于通用 CLI 工具和编译型工具链。
  例如：`gh`、`clangd`、`clang-format`、`ruff`、`shellcheck`、`marksman`、`cmake`、`ninja`。
- **用户级 npm**：用于需要在 Neovim 之外也能复用的语言服务和工具。
  例如：`bash-language-server`、`markdown-toc`、`markdownlint-cli2`、`pyright`、`yaml-language-server`。
- **Mason**：用于只服务编辑器、不需要单独做系统级生命周期管理的工具。
  例如：`lua-language-server`、`stylua`、`taplo`、`rust-analyzer`、`shfmt`、`debugpy`、`codelldb`。

规则：

- 每个工具尽量只保留一个生效来源。
- 如果某个工具开始在 Neovim 之外也经常使用，就应当从 Mason 迁移到系统包管理器或用户级 npm。
- Neovim 的 Mason 去重逻辑按实际命令路径判断。
  只有当工具存在于 Mason 目录之外时，才会从 Mason 的安装列表里移除或设置 `mason = false`。

## 不纳入版本控制

机器状态、缓存、历史记录、SSH 密钥、应用令牌、VS Code 全局存储目录，以及下载得到的插件目录，都不应该进入这个仓库。

## 主机

| 主机 | 系统 | 角色 |
|------|------|------|
| MiniHan | Arch Linux | 主力工作站、开发容器宿主 |
| WinHan | Windows 11 | IM 智能体主控、游戏/串流 |
