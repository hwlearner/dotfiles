--[[
=============================================================================
  10-treesitter.lua — Treesitter 语法高亮
=============================================================================
  使用 vim.pack 原生包管理器（Neovim 0.12+）
=============================================================================
]]

-- PackChanged 钩子：更新后自动安装/更新 parser
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "nvim-treesitter" and kind == "update" then
      if not ev.data.active then vim.cmd.packadd("nvim-treesitter") end
      vim.cmd("TSUpdate")
    end
  end,
})

vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
})

require("nvim-treesitter").setup({
  highlight = { enable = true },
  indent = { enable = true },
  ensure_installed = {
    "lua", "vim", "vimdoc",
    "javascript", "typescript", "tsx",
    "html", "css", "json", "yaml", "xml",
    "markdown", "markdown_inline",
    "bash", "python",
    "diff", "regex", "query",
  },
})
