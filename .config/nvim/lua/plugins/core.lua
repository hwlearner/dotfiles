--[[
=============================================================================
  core.lua — 基础插件（高亮、图标、配对、按键提示）
=============================================================================
  清单：
  - nvim-treesitter      → 语法高亮、缩进、折叠
  - mini.icons           → 文件类型图标
  - mini.pairs           → 自动配对括号/引号
  - which-key.nvim       → 按键提示弹窗
  - gitsigns.nvim        → Git 增删改标记（行号旁）
=============================================================================
]]

return {
  -- ============================================================
  -- Treesitter — 比 regex 更智能的语法高亮
  -- ============================================================
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = function()
      -- 安装 parser（需要 C 编译器）
      local ts = require("nvim-treesitter")
      if ts.get_installed then
        ts.update(nil, { summary = true })
      end
    end,
    event = { "VeryLazy" },
    cmd = { "TSUpdate", "TSInstall", "TSUninstall" },

    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      -- 只装你需要的语言 parser（减少 build 时间）
      ensure_installed = {
        "lua", "vim", "vimdoc",
        "javascript", "typescript", "tsx",
        "html", "css", "json", "yaml", "xml",
        "markdown", "markdown_inline",
        "bash", "python",
        "diff", "regex", "query",
      },
    },

    config = function(_, opts)
      require("nvim-treesitter").setup(opts)
    end,
  },

  -- ============================================================
  -- mini.icons — 文件/目录/文件类型图标
  -- ============================================================
  -- 很多插件依赖图标提供者（lualine、bufferline、telescope 等）
  -- mini.icons 可以 mock nvim-web-devicons 的接口
  {
    "nvim-mini/mini.icons",
    lazy = true,
    init = function()
      -- 让依赖 nvim-web-devicons 的插件透明地使用 mini.icons
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  -- ============================================================
  -- mini.pairs — 自动补全配对标点
  -- ============================================================
  {
    "nvim-mini/mini.pairs",
    event = "VeryLazy",
    opts = {
      modes = { insert = true, command = true, terminal = false },
      -- 下一个字符是字母/数字时跳过自动配对（避免括号内误配对）
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      -- 在 treesitter string 节点内跳过配对
      skip_ts = { "string" },
      -- 当闭合括号比开放括号多时不配对
      skip_unbalanced = true,
      -- markdown 代码块特殊处理
      markdown = true,
    },
  },

  -- ============================================================
  -- which-key — 输入前缀键时弹出可用按键列表
  -- ============================================================
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      spec = {
        { "<leader>c", group = "代码" },
        { "<leader>f", group = "文件/搜索" },
        { "<leader>g", group = "Git" },
        { "<leader>b", group = "缓冲" },
        { "<leader>w", group = "窗口" },
        { "<leader>u", group = "界面" },
        { "<leader>q", group = "退出/会话" },
      },
    },
    keys = {
      { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "缓冲按键" },
    },
  },

  -- ============================================================
  -- gitsigns — 行号旁显示 Git 增删改标记
  -- ============================================================
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = function(buf)
        local gs = package.loaded.gitsigns
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc, silent = true })
        end
        map("n", "]h", function() gs.nav_hunk("next") end, "下一处更改")
        map("n", "[h", function() gs.nav_hunk("prev") end, "上一处更改")
        map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "暂存更改")
        map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "撤销更改")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "代码溯源")
        map("n", "<leader>ghd", gs.diffthis, "查看差异")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "选择更改区域")
      end,
    },
  },
}
