--[[
=============================================================================
  editor.lua — 编辑器 UI 增强
=============================================================================
  -- mini.statusline — 状态栏（模式/文件名/git/诊断/行号）
  --               与 mini.icons 配合显示文件类型图标
=============================================================================
]]

return {
  {
    "nvim-mini/mini.statusline",
    event = "VeryLazy",

    opts = {
      -- 使用 mini.icons 的文件类型图标（需要 Nerd Font）
      use_icons = true,

      set_vim_settings = true,
    },

    config = function(_, opts)
      local statusline = require("mini.statusline")
      statusline.setup(opts)
      -- mini.statusline.setup() 会覆盖 MiniStatusline* 高亮组，重新应用主题
      if vim.g.colors_name == "catppuccin" then
        vim.cmd.colorscheme("catppuccin")
      end

      -- 汉化模式名：NORMAL → 普通，INSERT → 插入 等
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

      -- 汉化行号/列号标签：Ln → 行，Col → 列
      statusline.section_location = function()
        return string.format("行 %d, 列 %d", vim.fn.line("."), vim.fn.virtcol("."))
      end
    end,
  },
}
