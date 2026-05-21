--[[
=============================================================================
  lazy.lua — 包管理器 lazy.nvim 的安装和引导
=============================================================================
  lazy.nvim 的特性：
  - 按需加载（event / cmd / keys / ft 触发）
  - 自动管理依赖
  - opts 合并机制（插件级覆盖，无需 fork）
  - 锁文件 lazy-lock.json 锁定版本
  - :Lazy 图形化 UI
=============================================================================
]]

-- 1. 本地没有 lazy.nvim 时自动 clone
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", repo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- 2. 启动 lazy.nvim，加载 lua/plugins/ 下的所有配置
require("lazy").setup({
  spec = {
    { import = "plugins" },         -- 自动加载 lua/plugins/*.lua
  },
  defaults = {
    lazy = true,                     -- 所有插件默认懒加载
    version = false,                 -- 默认跟踪最新（不锁定版本）
  },
  install = {
    colorscheme = { "catppuccin" },  -- 安装插件时用的主题
  },
  git = {
    url_format = "git@github.com:%s.git",  -- SSH 协议，国内更稳定
  },
  checker = {
    enabled = false,                 -- 不自动检查更新（手动 :Lazy update）
  },
  performance = {
    cache = {
      enabled = true,                -- 缓存已加载的插件列表，加速启动
    },
  },
  ui = {
    border = "rounded",
    icons = {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💤",
      source = "📄",
      start = "🚀",
      task = "📌",
      copylsp = "📋",
    },
  },
})
