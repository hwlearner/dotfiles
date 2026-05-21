# AGENTS.md — AI 助手工作指南

> 本文件供代码助手（如 Claude/Copilot/Cursor）理解本项目的行为准则。

本 Neovim 配置位于 `~/Projects/dotfiles/.config/nvim/`，通过 symlink 链接到
`~/.config/nvim`，为 dotfiles 仓库的一部分。

目标是**完全理解每一行配置**，从最小化起点逐步构建，而非使用 LazyVim 等大而全的发行版。

## 目录结构

```
~/.config/nvim/
├── AGENTS.md                # AI 助手工作指南（本文件）
├── init.lua                 # 入口
├── keybinds-diff.md         # 快捷键对照表（vs LazyVim）
├── lazy-lock.json           # 插件版本锁定（由 lazy.nvim 自动管理）
├── lua/
│   ├── config/
│   │   ├── options.lua      # Neovim 基础设置
│   │   ├── keymaps.lua      # 核心按键映射
│   │   └── lazy.lua         # lazy.nvim 引导
│   └── plugins/
│       ├── ai.lua           # AI 代码补全（minuet-ai + DeepSeek）
│       ├── core.lua         # 基础插件（treesitter, icons, pairs, which-key, gitsigns）
│       ├── colorscheme.lua  # catppuccin 主题（自动深浅切换）
│       ├── editor.lua       # UI 增强（statusline）
│       ├── lsp.lua          # LSP 客户端（lspconfig + mason）
│       └── formatting.lua   # 代码格式化（conform.nvim）
```

## 技术栈

- **Neovim** >= 0.11 (LuaJIT 构建)
- **包管理器**：[lazy.nvim](https://github.com/folke/lazy.nvim)
- **主题**：[catppuccin/nvim](https://github.com/catppuccin/nvim)，跟随 macOS 系统深浅色自动切换
- **终端**：需要 Nerd Font 以显示图标

## 配置原则

1. **每一行都有注释** — 新增配置必须附中文注释说明作用
2. **不引入无意义的依赖** — 加插件前先确认：真的需要？能不能用 Neovim 内置功能？
3. **按键分组一致** — 沿用 LazyVim 的 `<leader>` 前缀约定（`<leader>c`=代码，`<leader>g`=git 等）
4. **懒加载优先** — 所有插件默认 `lazy = true`，通过 `event`/`cmd`/`keys`/`ft` 触发加载
5. **最小改动原则** — 修改现有配置时，优先用 `opts` 合并，不改动原始包源码

## 插件管理命令

| 命令 | 作用 |
|------|------|
| `:Lazy` | 打开插件管理 UI |
| `:Lazy update` | 更新所有插件 |
| `:Lazy check` | 检查插件更新 |
| `:Mason` | 管理 LSP 服务器/格式化器 |
| `:TSInstall <lang>` | 安装 Treesitter parser |
| `:ConformInfo` | 查看当前文件格式化器 |

## 主题切换说明

catppuccin 配置为 `flavour = "auto"`，自动读取 `vim.o.background`。

- macOS 启动时检测 `defaults read -g AppleInterfaceStyle` 设置背景色
- 在 Neovim 内手动切换：`:set background=light` / `:set background=dark`
- 如需实时跟随系统变化（不需手动执行命令），可考虑安装系统级工具如 `dark-mode-notify` 或 terminal 集成方案

## 给 AI 的约束

- 所有面向用户的回复、注释、commit message 使用**简体中文**
- 新增配置保持现有文件结构，不要创建多余的 init.lua 或混乱嵌套
- 修改后验证语法正确性：`:Lazy` 能正常打开即基本可用
