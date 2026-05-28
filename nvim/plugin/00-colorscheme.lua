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

})

-- 配置 catppuccin
require("catppuccin").setup({
  flavour = "auto",          -- 跟随 vim.o.background
  term_colors = false,
  transparent_background = true,
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

-- 监听 darkman 主题切换（读取共享模式文件）
local mode_file = "/home/han/.pi/agent/current-mode"

local function check_mode()
  local ok, content = pcall(vim.fn.readfile, mode_file)
  if ok and content and #content > 0 then
    local mode = vim.trim(content[1])
    if mode == "light" then
      vim.opt.background = "light"
    elseif mode == "dark" then
      vim.opt.background = "dark"
    end
  end
end

-- 启动时检查一次
vim.defer_fn(check_mode, 200)

-- hypr-mode.sh touch 此文件时触发检查
local ok, watcher = pcall(vim.uv.new_fs_event)
if ok and watcher then
  watcher:start("/tmp/nvim-recheck-bg", { stat = true }, vim.schedule_wrap(function()
    check_mode()
  end))
end

-- VimResume 时也检查一次
vim.api.nvim_create_autocmd("VimResume", {
  callback = check_mode,
})
