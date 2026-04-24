# dotfiles

我的跨平台开发环境配置。

## 目录结构

- `.zshrc`、`.zprofile`、`.tmux.conf`、`.gitconfig`：Shell、tmux 和 Git 的基础配置。
- `.aerospace.toml`：AeroSpace 窗口管理器配置。
- `.markdownlint.yaml`：共享的 markdownlint 规则。
- `nvim/`：来自 `~/.config/nvim` 的 Neovim 配置。
- `nvim-vscode/`：来自 `~/.config/nvim-vscode` 的 VS Code Neovim 桥接配置。
- `ghostty/`：来自 `~/.config/ghostty` 的 Ghostty 配置。
- `hammerspoon/`：来自 `~/.hammerspoon` 的 Hammerspoon 自动化配置。
- `git/ignore`：来自 `~/.config/git/ignore` 的全局 Git 忽略规则。
- `vscode/`：VS Code 用户设置、快捷键、语言配置和扩展列表。
- `autoconfig.yml`、`quickmarks`：仓库中保留的旧版 qutebrowser 配置。

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
