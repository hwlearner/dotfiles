--[[
=============================================================================
  00-colorscheme.lua — 主题（随系统深浅色自动切换）
=============================================================================
  使用 vim.pack 原生包管理器（Neovim 0.12+）
=============================================================================
]]

-- 立即安装并加载主题插件（使用 name 避免目录名混淆）
vim.pack.add({
  { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },
  'https://github.com/afonsofrancof/OSC11.nvim',
})

-- 配置 catppuccin
require("catppuccin").setup({
  flavour = "auto",          -- 跟随 vim.o.background
  term_colors = false,
  integrations = {
    cmp = true,
    gitsigns = true,
    indent_blankline = { enabled = true },
    illuminate = true,
    lsp_trouble = true,
    mason = true,
    mini = true,
    native_lsp = { enabled = true },
    treesitter = true,
    which_key = true,
  },
})

-- 立即应用主题
vim.cmd.colorscheme("catppuccin")

-- OSC11 — 终端主题变化时实时通知 Neovim
require("osc11").setup({
  on_dark = function() vim.opt.background = "dark" end,
  on_light = function() vim.opt.background = "light" end,
})
