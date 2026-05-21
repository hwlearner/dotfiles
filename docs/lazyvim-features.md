# LazyVim 功能概览：相比原生 Neovim 增加了什么

> 核心机制：基于 lazy.nvim 插件管理器，提供预配置的插件集 + 开箱即用的设置/按键/自动命令。

> 标注说明：
> - **✅** = 已包含在 `minimal-config` 中
> - **🔶** = 部分实现（简化版）
> - **❌** = 未包含
> - **—** = 不适用（LazyVim 自有框架）

---

## 一、基础层（无需额外插件，内置）

| 增强项 | 说明 | 覆盖 |
|--------|------|------|
| 合理默认值 | options.lua：相对行号、全局状态栏、折叠、undofile、自动写入、smartcase、`<leader>` 为空格、tab=2 空格、鼠标启用、clipboard 自动同步、timeoutlen=300ms 等 | ✅ |
| 全局按键映射 | keymaps.lua：窗口导航 `<C-hjkl>`、窗口大小调整、行移动 `<A-j/k>`、Buffer 切换、保存 `<C-s>`、格式化 `<leader>cf`、诊断跳转等 | ✅ |
| 自动命令 | autocmds.lua：Yank 高亮、焦点恢复 checktime、窗口缩放自动等分、保存时自动创建目录、`q` 关闭帮助/诊断等浮动窗口、markdown/text 自动换行+拼写 | 🔶 仅 `q` 关闭浮动窗口 |

---

## 二、核心框架

| 功能 | 依赖包 | 说明 | 覆盖 |
|------|--------|------|------|
| 插件懒加载管理 | `folke/lazy.nvim` | 按需加载插件，启动快，内置 UI 管理界面 `<leader>l` | ✅ |
| 插件配置框架 | `LazyVim/LazyVim` | 统一 opt/keys/cmd/event 定义，支持插件 specs 合并 | ❌ 最小配置从零手动配，不依赖此框架 |
| 多功能 UI 组件库 | `folke/snacks.nvim` | 缩进线、通知、滚动条、状态栏列、作用域高亮、缩放/禅模式、终端、lazygit 集成、文件重命名、profiler、words、picker、动画、dim、toggle 系统 | ❌ |
| 图标 | `nvim-mini/mini.icons` | 文件类型图标，mock nvim-web-devicons 接口 | ✅ |
| UI 组件工具库 | `MunifTanjim/nui.nvim` | 被其他插件依赖的浮窗/输入组件 | ❌ |

---

## 三、编辑器增强

| 功能 | 依赖包 | 说明 | 覆盖 |
|------|--------|------|------|
| 按键提示 | `folke/which-key.nvim` | 输入前缀键时弹出可用按键列表 | ✅ |
| 标签栏 | `akinsho/bufferline.nvim` | 带图标和关闭按钮的 Buffer 标签栏 | ❌ |
| 状态栏 | `nvim-lualine/lualine.nvim` | 显示模式、git 分支、诊断、文件路径、diff、进度等 | 🔶 已用 `mini.statusline` 替代 |
| Git 标记 | `lewis6991/gitsigns.nvim` | 行号旁显示增删改标记，支持 hunk stage/reset/blame | ✅ |
| 搜索替换 | `MagicDuck/grug-far.nvim` | 跨文件搜索和替换 | ❌ 可用原生 `:cfdo` / `:cdo` |
| 快速跳转 | `folke/flash.nvim` | 增强搜索，标签跳转，treesitter 选区 | ❌ |
| 诊断/符号列表 | `folke/trouble.nvim` | 统一显示诊断、符号、LSP 引用、quickfix | ❌ |
| TODO 注释 | `folke/todo-comments.nvim` | 高亮并浏览 TODO/FIX/BUG/HACK 注释 | ❌ |

---

## 四、编码辅助

| 功能 | 依赖包 | 说明 | 覆盖 |
|------|--------|------|------|
| 自动配对 | `nvim-mini/mini.pairs` | 自动补全引号、括号、花括号 | ✅ |
| 注释增强 | `folke/ts-comments.nvim` | 基于 Treesitter 的注释检测，支持多种注释符号 | ❌ 原生 `gcc`/`gc` 已可用 |
| 扩展文本对象 | `nvim-mini/mini.ai` | 选择参数、函数、类、标签、数字等文本对象 | ❌ |
| Lua 开发辅助 | `folke/lazydev.nvim` | 编辑 Neovim 配置时提供 LuaLS 类型提示和补全 | ❌ |

---

## 五、Treesitter（语法解析）

| 功能 | 依赖包 | 说明 | 覆盖 |
|------|--------|------|------|
| 语法高亮/缩进/折叠 | `nvim-treesitter/nvim-treesitter` | 22 种默认安装的 parser | 🔶 已安装，但 parsers 列表精简为 15 种 |
| Treesitter 文本对象 | `nvim-treesitter/nvim-treesitter-textobjects` | 按函数/类/参数跳转 `]f` `[c` `]a` | ❌ |
| 自动闭合标签 | `windwp/nvim-ts-autotag` | HTML/JSX/TSX 标签自动闭合 | ❌ |

---

## 六、LSP（语言服务器协议）

| 功能 | 依赖包 | 说明 | 覆盖 |
|------|--------|------|------|
| LSP 客户端配置 | `neovim/nvim-lspconfig` | 统一配置各语言 LSP 服务器 | ✅ |
| LSP 安装器 | `mason.nvim` + `mason-lspconfig.nvim` | 命令行安装 LSP 服务器、格式化工具 | ✅ |
| LSP 按键 | 内置（keymaps.lua） | gd 定义、gr 引用、K 悬停、`<leader>ca` 代码操作、`<leader>cr` 重命名等 | ✅ 在 `lsp.lua` 中统一配置 |
| Inlay Hints | 内置（lsp/init.lua） | 内联参数/类型提示 | ❌ |
| CodeLens | 内置（lsp/init.lua，默认关闭） | 代码镜头（运行/引用计数） | ❌ |

---

## 七、格式化与 Lint

| 功能 | 依赖包 | 说明 | 覆盖 |
|------|--------|------|------|
| 代码格式化 | `stevearc/conform.nvim` | 按文件类型自动/手动格式化（stylua/shfmt 预装） | ✅ |
| 代码检查 | `mfussenegger/nvim-lint` | BufWritePost/InsertLeave 时异步 lint | ❌ 原生 `:make` / `makeprg` 可替代 |

---

## 八、消息/命令行 UI

| 功能 | 依赖包 | 说明 | 覆盖 |
|------|--------|------|------|
| 消息/命令行替换 | `folke/noice.nvim` | 用浮动窗口替换 vim 原生的消息区域和命令行 | ❌ |

---

## 九、色彩主题

| 功能 | 依赖包 | 说明 | 覆盖 |
|------|--------|------|------|
| 主题 | `folke/tokyonight.nvim` | LazyVim 默认主题（moon 风格） | ❌ |
| 主题 | `catppuccin/nvim` | 可选，深度集成所有 LazyVim 插件 | ✅ 且支持自动深浅切换 |

---

## 十、可选扩展（:LazyExtras 启用）

按类别列举主要扩展：

| 类别 | 功能 | 依赖包 | 覆盖 |
|------|------|--------|------|
| **补全引擎** | 代码补全（默认） | `Saghen/blink.cmp` | ❌ |
| | 代码补全（旧版） | `hrsh7th/nvim-cmp` | ❌ |
| | 代码片段 | `L3MON4D3/LuaSnip` / `nvim-mini/mini.snippets` | ❌ |
| **文件管理器** | 文件树 | `nvim-neo-tree/neo-tree.nvim` | ❌ 原生 Netrw 可用 |
| **模糊搜索** | Telescope | `nvim-telescope/telescope.nvim` | ❌ 原生 `:find` / `:grep` 可用 |
| | fzf-lua | `ibhagwan/fzf-lua` | ❌ |
| **调试** | DAP | `mfussenegger/nvim-dap` + `rcarriga/nvim-dap-ui` | ❌ |
| **AI** | Copilot / Codeium / Supermaven / Tabnine / Avante 等 | 各自对应插件 | ❌ |
| **测试** | Neotest | `nvim-neotest/neotest` | ❌ |
| **符号大纲** | Aerial / Outline | `stevearc/aerial.nvim` / `hedyhli/outline.nvim` | ❌ |
| **跳转导航** | Harpoon / Leap / Illuminated | 各自对应插件 | ❌ |
| **编辑增强** | mini-surround / mini-comment / yanky / refactoring | 各自对应插件 | ❌ |
| **仪表盘** | alpha-nvim / dashboard-nvim / mini.starter | 各自对应插件 | ❌ |
| **语言支持** | clangd / typescript / rust / go / java / python / vue 等 | 121+ 语言扩展文件 | 🔶 框架已配好，按需取消注释即可 |

---

## 统计

| 级别 | 功能数 |
|------|--------|
| ✅ 已覆盖 | 11 |
| 🔶 部分覆盖 | 3 |
| ❌ 未覆盖 | 28+ |
| — 不适用 | 1 |

> **总结**：`minimal-config` 覆盖了 LazyVim 约 **11/42** 的核心功能，涵盖最刚需的部分（包管理、LSP、格式化、Treesitter 高亮、Git 标记、按键提示、自动配对、主题）。其余功能按需逐步添加，每加一个都是自己掌控的。
