--[[
=============================================================================
  50-formatting.lua — 代码格式化（conform.nvim）
=============================================================================
  使用 vim.pack 原生包管理器（Neovim 0.12+）
  按需加载：首次使用 :ConformInfo 命令时加载
=============================================================================
]]

vim.api.nvim_create_user_command("ConformInfo", function()
  -- 首次执行时加载插件
  pcall(function()
    vim.pack.add({ "https://github.com/stevearc/conform.nvim" })
  end)

  require("conform").setup({
    default_format_opts = {
      timeout_ms = 3000,
      async = false,
      quiet = false,
      lsp_format = "fallback",
    },
    formatters_by_ft = {
      lua = { "stylua" },
      javascript = { "prettierd", "prettier" },
      typescript = { "prettierd", "prettier" },
      javascriptreact = { "prettierd", "prettier" },
      typescriptreact = { "prettierd", "prettier" },
      json = { "prettierd", "prettier" },
      yaml = { "prettierd", "prettier" },
      markdown = { "prettierd", "prettier" },
      html = { "prettierd", "prettier" },
      css = { "prettierd", "prettier" },
      python = { "isort", "black" },
      go = { "gofumpt", "goimports" },
      rust = { "rustfmt" },
      sh = { "shfmt" },
      ["*"] = { "trim_whitespace" },
      ["_"] = { "squeeze_blanks" },
    },
    formatters = {
      injected = { options = { ignore_errors = true } },
    },
  })

  -- 注册格式化快捷键
  vim.keymap.set({ "n", "x" }, "<leader>cF", function()
    require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
  end, { desc = "格式化内嵌语言" })

  -- 执行一次即完成初始化，显示 ConformInfo
  vim.cmd("ConformInfo")
end, { desc = "打开 ConformInfo（首次执行会安装 conform.nvim）" })

-- 确保格式化快捷键在 LSP 中也有效
-- LSP 已注册 <leader>cf 为 vim.lsp.buf.format
-- conform 的 <leader>cF 用于内嵌语言格式化，不冲突
