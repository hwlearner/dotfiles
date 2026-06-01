--[[
=============================================================================
  options.lua — Neovim 基础设置
=============================================================================
  这里只放最核心的、你一定会用到的设置。
  所有值都从 LazyVim 的 options.lua 中精选，每行附说明。
=============================================================================
]]

local opt = vim.opt

opt.autoindent = true          -- 自动缩进
opt.autowrite = true           -- 切换 buffer 时自动保存
opt.clipboard = "unnamedplus"  -- 与系统剪贴板同步
opt.completeopt = "menu,menuone,noselect,popup"
opt.conceallevel = 2           -- 隐藏 markdown 标记字符
opt.confirm = true             -- 退出未保存 buffer 前确认
opt.cursorline = true          -- 高亮当前行
opt.expandtab = true           -- 用空格代替 Tab
opt.foldlevel = 99             -- 默认展开所有折叠
opt.foldmethod = "indent"      -- 基于缩进的折叠
opt.ignorecase = true          -- 搜索忽略大小写
opt.inccommand = "nosplit"     -- 实时预览替换
opt.helplang = "zh"           -- 中文帮助优先
opt.laststatus = 3             -- 全局状态栏（单条）
opt.list = true                -- 显示不可见字符
opt.mouse = "a"                -- 启用鼠标
opt.number = true              -- 显示行号
opt.pumheight = 10             -- 补全弹窗最大行数
opt.relativenumber = true      -- 相对行号
opt.scrolloff = 4              -- 光标上下保留行数
opt.shiftwidth = 2             -- 缩进宽度
opt.showmode = false           -- 底部不显示模式（状态栏已有）
opt.signcolumn = "yes"         -- 始终保留符号列（避免跳动）
opt.smartcase = true           -- 搜索包含大写时区分大小写
opt.smartindent = true         -- 智能缩进
opt.smoothscroll = true        -- 平滑滚动
opt.splitbelow = true          -- 分屏在下方
opt.splitright = true          -- 分屏在右侧
opt.tabstop = 2                -- Tab 宽度
opt.termguicolors = true       -- 真彩色
opt.timeoutlen = 300           -- 按键序列超时（which-key 响应速度）
opt.undofile = true            -- 持久化撤销历史
opt.updatetime = 200           -- 触发 CursorHold 的延迟（ms）
opt.wildmode = "longest:full,full"
opt.wrap = false               -- 不自动换行

-- leader 键设置为空格
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- catppuccin 会自动跟随终端主题（通过 OSC11.nvim）
vim.o.background = "dark"
