--[[
=============================================================================
  30-editor.lua — 编辑器 UI 增强（状态栏）
=============================================================================
  使用 vim.pack 原生包管理器（Neovim 0.12+）
=============================================================================
]]

vim.pack.add({ "https://github.com/nvim-mini/mini.statusline" })

local statusline = require("mini.statusline")
statusline.setup({
  use_icons = true,
  set_vim_settings = true,
})

-- mini.statusline.setup() 会覆盖 MiniStatusline* 高亮组，重新应用主题
if vim.g.colors_name == "catppuccin" then
  vim.cmd.colorscheme("catppuccin")
end

-- 汉化模式名
statusline.section_mode = function()
  local mode = vim.fn.mode()
  local mode_map = {
    n = "普通", i = "插入", v = "可视", V = "可视行",
    ["\22"] = "可视块", c = "命令", s = "选择",
    S = "选择行", ["\19"] = "选择块", t = "终端",
    R = "替换", r = "提示", ["!"] = "Shell",
  }
  local hl_map = {
    n = "MiniStatuslineModeNormal",
    i = "MiniStatuslineModeInsert",
    v = "MiniStatuslineModeVisual",
    V = "MiniStatuslineModeVisual",
    ["\22"] = "MiniStatuslineModeVisual",
    c = "MiniStatuslineModeCommand",
    s = "MiniStatuslineModeVisual",
    S = "MiniStatuslineModeVisual",
    ["\19"] = "MiniStatuslineModeVisual",
    t = "MiniStatuslineModeOther",
    R = "MiniStatuslineModeReplace",
    r = "MiniStatuslineModeOther",
    ["!"] = "MiniStatuslineModeOther",
  }
  return mode_map[mode] or mode, hl_map[mode] or "MiniStatuslineModeOther"
end

-- 汉化行号/列号标签
statusline.section_location = function()
  return string.format("行 %d, 列 %d", vim.fn.line("."), vim.fn.virtcol("."))
end
