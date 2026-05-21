--[[
=============================================================================
  formatting.lua — 代码格式化
=============================================================================
  conform.nvim 特点：
  - 异步调用外部格式化工具
  - 按文件类型自动选择格式化器
  - 支持 LSP fallback（如果某语言没有外部格式化器，fallback 到 LSP）
=============================================================================
]]

return {
  {
    "stevearc/conform.nvim",
    lazy = true,
    cmd = "ConformInfo",

    opts = {
      -- 格式化选项
      default_format_opts = {
        timeout_ms = 3000,
        async = false,
        quiet = false,
        lsp_format = "fallback",   -- 没有外部格式化器时回退到 LSP
      },
      -- 按文件类型指定格式化器
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
        ["*"] = { "trim_whitespace" },           -- 所有文件类型：清除行尾空格
        ["_"] = { "squeeze_blanks" },            -- 未匹配的文件类型：压缩空行
      },
      -- 自定义格式化器配置（按需添加）
      formatters = {
        injected = { options = { ignore_errors = true } },
      },
    },

    -- 注册格式化命令
    keys = {
      { "<leader>cF", function()
        require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
      end, mode = { "n", "x" }, desc = "格式化内嵌语言" },
    },
  },
}
