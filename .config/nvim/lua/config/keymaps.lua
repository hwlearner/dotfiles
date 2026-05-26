--[[
=============================================================================
  keymaps.lua — 核心按键映射
=============================================================================
  规则：
  - 每个 map 都加了 desc，便于 which-key 显示
  - 分组前缀约定（跟 LazyVim 一致，方便以后迁移）：
    <leader>f  → 文件/搜索
    <leader>g  → git
    <leader>c  → 代码
    <leader>w  → 窗口
    <leader>b  → buffer
    <leader>u  → UI toggle
=============================================================================
]]

local map = vim.keymap.set

-- 更智能的上下移动（处理折行）
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "向下" })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "向上" })

-- 窗口导航（Ctrl + hjkl）
map("n", "<C-h>", "<C-w>h", { desc = "左窗口" })
map("n", "<C-j>", "<C-w>j", { desc = "下窗口" })
map("n", "<C-k>", "<C-w>k", { desc = "上窗口" })
map("n", "<C-l>", "<C-w>l", { desc = "右窗口" })

-- 窗口大小调整（Ctrl + 方向键）
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "增加高度" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "减少高度" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "减少宽度" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "增加宽度" })

-- Buffer 操作
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "上一个缓冲" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "下一个缓冲" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "切换缓冲" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "删除缓冲" })
map("n", "<leader>bo", "<cmd>%bdelete|edit #|bdelete #<cr>", { desc = "删除其他缓冲" })

-- 保存
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "保存文件" })
-- 包管理（vim.pack 原生包管理器）
map("n", "<leader>l", function() vim.pack.update(nil, { offline = true }) end, { desc = "插件状态" })
map("n", "<leader>L", function() vim.pack.update() end, { desc = "插件更新" })

-- 取消高亮（按 Esc）
map({ "i", "n", "s" }, "<esc>", function()
  vim.cmd("noh")
  return "<esc>"
end, { expr = true, desc = "取消高亮搜索" })

-- 搜索跳转后保持居中
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "下一个搜索结果" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "上一个搜索结果" })

-- 更好的缩进（保持选中）
map("x", "<", "<gv", { desc = "左缩进" })
map("x", ">", ">gv", { desc = "右缩进" })

-- 行上移/下移
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "下移行" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "上移行" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "下移选择" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "上移选择" })

-- 分屏
map("n", "<leader>-", "<C-W>s", { desc = "下分屏" })
map("n", "<leader>|", "<C-W>v", { desc = "右分屏" })
map("n", "<leader>wd", "<C-W>c", { desc = "关闭窗口" })

-- 快速退出
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "全部退出" })

-- LSP 相关按键（在 plugins/lsp.lua 中进一步补充）
map("n", "<leader>cf", function()
  vim.lsp.buf.format({ async = false })
end, { desc = "格式化代码" })

-- 按 q 关闭常见的浮动窗口（帮助/诊断等）
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "help", "qf", "checkhealth", "lspinfo", "notify",
    "neotest-output", "neotest-summary",
  },
  callback = function(ev)
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true, desc = "关闭窗口" })
  end,
})
