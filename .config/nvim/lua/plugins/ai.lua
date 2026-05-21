--[[
=============================================================================
  ai.lua — AI 代码补全
=============================================================================
  -- minuet-ai.nvim — 调用 DeepSeek API 实现类 Copilot 的 AI 补全
  --               使用虚拟文本显示灰色预览（virtual text）
  --               需要设置环境变量 DEEPSEEK_API_KEY
  --               (https://platform.deepseek.com/api_keys)
=============================================================================
]]

return {
  {
    "milanglacier/minuet-ai.nvim",
    event = "VeryLazy",

    config = function()
      -- 没有 API Key 时不启用，避免报错
      if not vim.env.DEEPSEEK_API_KEY then
        vim.notify(
          "minuet-ai: 请设置 DEEPSEEK_API_KEY 环境变量",
          vim.log.levels.WARN
        )
        return
      end

      require("minuet").setup {
        -- === DeepSeek API 配置 ========================================
        provider = "openai_fim_compatible",
        provider_options = {
          openai_fim_compatible = {
            -- 填环境变量名，不是实际 key
            api_key = "DEEPSEEK_API_KEY",
            name = "deepseek",
            optional = {
              max_tokens = 256,
              top_p = 0.9,
            },
          },
        },

        -- === 虚拟文本（类 Copilot 灰色预览） ============================
        virtualtext = {
          -- 所有文件类型自动触发
          auto_trigger_ft = { "*" },

          keymap = {
            accept = "<A-]>",        -- 接受整段补全
            accept_line = "<A-\\>",   -- 只接受一行
            accept_n_lines = "<A-z>", -- 接受 N 行（会提示输入行数）
            dismiss = "<A-ESC>",      -- 取消当前补全
            next = "<A-=>",           -- 下一个候选
            prev = "<A-->",           -- 上一个候选
          },
        },

        -- === 性能调优 ==================================================
        throttle = 1000,                -- 两次请求间隔（毫秒）
        debounce = 400,                 -- 输入停顿后触发（毫秒）
        request_timeout = 3,            -- 超时（秒）
        context_window = 16000,         -- 发送的上下文最大字符数
      }
    end,
  },
}
