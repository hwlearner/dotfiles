--[[
=============================================================================
  60-ai.lua — AI 代码补全（minuet-ai.nvim + DeepSeek API）
=============================================================================
  使用 vim.pack 原生包管理器（Neovim 0.12+）
=============================================================================
]]

-- 没有 API Key 时不加载
if not vim.env.DEEPSEEK_API_KEY then
  vim.notify("minuet-ai: 请设置 DEEPSEEK_API_KEY 环境变量", vim.log.levels.WARN)
  return
end

vim.pack.add({ "https://github.com/milanglacier/minuet-ai.nvim" })

require("minuet").setup({
  provider = "openai_fim_compatible",
  provider_options = {
    openai_fim_compatible = {
      api_key = "DEEPSEEK_API_KEY",
      name = "deepseek",
      optional = {
        max_tokens = 256,
        top_p = 0.9,
      },
    },
  },
  virtualtext = {
    auto_trigger_ft = { "*" },
    keymap = {
      accept = "<A-]>",
      accept_line = "<A-\\>",
      accept_n_lines = "<A-z>",
      dismiss = "<A-ESC>",
      next = "<A-=>",
      prev = "<A-->",
    },
  },
  throttle = 1000,
  debounce = 400,
  request_timeout = 3,
  context_window = 16000,
})
