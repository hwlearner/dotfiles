--[[
=============================================================================
  20-core.lua — 基础插件（图标、配对、按键提示、Git 标记）
=============================================================================
  使用 vim.pack 原生包管理器（Neovim 0.12+）
=============================================================================
]]

-- ============================================================
-- mini.icons — 文件/目录图标
-- ============================================================
vim.pack.add({ "https://github.com/nvim-mini/mini.icons" })

-- mock nvim-web-devicons 接口供依赖它的插件使用
package.preload["nvim-web-devicons"] = function()
  require("mini.icons").mock_nvim_web_devicons()
  return package.loaded["nvim-web-devicons"]
end

-- ============================================================
-- mini.pairs — 自动配对括号/引号
-- ============================================================
vim.pack.add({ "https://github.com/nvim-mini/mini.pairs" })

require("mini.pairs").setup({
  modes = { insert = true, command = true, terminal = false },
  skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
  skip_ts = { "string" },
  skip_unbalanced = true,
  markdown = true,
})

-- ============================================================
-- which-key — 按键提示弹窗
-- ============================================================
vim.pack.add({ "https://github.com/folke/which-key.nvim" })

require("which-key").setup({
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
})

vim.keymap.set("n", "<leader>?", function()
  require("which-key").show({ global = false })
end, { desc = "缓冲按键" })

-- ============================================================
-- gitsigns — 行号旁显示 Git 增删改标记
-- ============================================================
-- 读取已有文件时自动加载
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  once = true,
  callback = function()
    vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })

    require("gitsigns").setup({
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
    })
  end,
})
