--[[
=============================================================================
  catppuccin 主题 — 自动跟随终端浅色/深色模式
=============================================================================
  工作机制：
  1. options.lua 在启动时检测 macOS 的 AppleInterfaceStyle
  2. 设置 vim.o.background = "light" 或 "dark"
  3. catppuccin 根据 vim.o.background 自动切换：
     - dark  → mocha
     - light → latte
=============================================================================
]]

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,                 -- 确保主题在其他插件之前加载
    lazy = false,                    -- 启动时立即加载（否则 config 不会执行）

    opts = {
      -- 根据系统外观自动选择 flavour
      flavour = "auto",              -- "auto" 会跟随 vim.o.background

      -- 关闭默认的终端真色检测（我们用 Neovim 的设置）
      term_colors = false,

      -- 集成配置
      integrations = {
        cmp = true,                  -- 补全弹窗
        gitsigns = true,             -- git 标记
        indent_blankline = {         -- 缩进线
          enabled = true,
        },
        illuminate = true,           -- 高亮同名字符
        lsp_trouble = true,
        mason = true,                -- LSP 安装器
        mini = true,                 -- mini.* 插件
        native_lsp = {
          enabled = true,
        },
        treesitter = true,
        which_key = true,            -- 按键提示
      },
    },

    -- 配置并应用主题（config 确保在 opts 合并后执行）
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- OSC11.nvim — 终端主题变化时实时通知 Neovim
  {
    "afonsofrancof/OSC11.nvim",
    lazy = false,
    opts = {
      on_dark = function()
        vim.opt.background = "dark"
      end,
      on_light = function()
        vim.opt.background = "light"
      end,
    },
  },
}
