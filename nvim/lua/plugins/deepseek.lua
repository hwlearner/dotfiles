return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    keys = {
      { "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", desc = "AI Chat Toggle" },
      { "<leader>ac", "<cmd>CodeCompanionChat<cr>", desc = "AI Chat" },
      { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "AI Actions", mode = "v" },
      { "<leader>aq", "<cmd>CodeCompanionChat Add<cr>", desc = "Quick Chat", mode = "v" },
    },
    opts = {
      strategies = {
        chat = {
          adapter = "deepseek",
          roles = {
            llm = "DeepSeek",
            user = "Han",
          },
        },
        inline = {
          adapter = "deepseek",
        },
      },
      adapters = {
        deepseek = function()
          return require("codecompanion.adapters").extend("deepseek", {
            name = "DeepSeek",
            env = {
              api_key = "DEEPSEEK_API_KEY",
            },
            schema = {
              model = {
                default = "deepseek-chat",
                choices = {
                  ["deepseek-chat"] = {},
                  ["deepseek-reasoner"] = {},
                },
              },
            },
          })
        end,
      },
      display = {
        chat = {
          show_header_separator = false,
        },
        diff = {
          enabled = true,
        },
      },
      opts = {
        log_level = "WARN",
      },
    },
  },
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      sources = {
        providers = {
          codecompanion = {
            name = "CodeCompanion",
            module = "codecompanion.providers.completion.blink",
            enabled = true,
            opts = { keybindings = { accept = "<C-y>" } },
          },
        },
      },
    },
  },
}
