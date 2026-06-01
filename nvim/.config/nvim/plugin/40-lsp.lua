--[[
=============================================================================
  40-lsp.lua — LSP 客户端（lspconfig + mason）
=============================================================================
  使用 vim.pack 原生包管理器（Neovim 0.12+）
=============================================================================
]]

-- 打开已有文件时加载 LSP
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  once = true,
  callback = function()
    vim.pack.add({
      "https://github.com/neovim/nvim-lspconfig",
      "https://github.com/williamboman/mason.nvim",
      "https://github.com/williamboman/mason-lspconfig.nvim",
    })

    -- ============================================================
    -- 诊断设置
    -- ============================================================
    vim.diagnostic.config({
      underline = true,
      update_in_insert = false,
      virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
      severity_sort = true,
    })

    -- ============================================================
    -- LspAttach 按键映射
    -- ============================================================
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
      callback = function(ev)
        local buf = ev.buf
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client then return end

        local has = function(cap)
          return client.server_capabilities[cap .. "Provider"] ~= nil
              or client.server_capabilities[cap] ~= nil
        end

        if client:supports_method("textDocument/completion") then
          vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })
        end

        -- 自定义映射（0.12 已自带 K/gd/gr/gy/[d/]d 等默认映射）
        local sk = function(lhs, rhs, desc, cap)
          if not cap or has(cap) then
            vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc, silent = true })
          end
        end
        sk("<leader>cf", function()
          vim.lsp.buf.format({ async = false, bufnr = buf })
        end, "格式化")
        sk("gI", vim.lsp.buf.implementation, "跳转实现", "implementation")
        sk("<leader>ca", vim.lsp.buf.code_action, "代码操作", "codeAction")
        sk("<leader>cr", vim.lsp.buf.rename, "重命名", "rename")
        sk("<leader>cd", vim.diagnostic.open_float, "行诊断")
        sk("gK", vim.lsp.buf.signature_help, "签名帮助", "signatureHelp")
        sk("<leader>cl", "<cmd>LspInfo<cr>", "LSP 信息")
        sk("<leader>co", function()
          vim.lsp.buf.code_action({
            context = { only = { "source.organizeImports" } },
            apply = true,
          })
        end, "整理导入", "codeAction")
      end,
    })

    -- ============================================================
    -- LSP 服务器配置
    -- ============================================================
    vim.lsp.config("*", {
      capabilities = {
        workspace = {
          fileOperations = {
            didRename = true,
            willRename = true,
          },
        },
      },
    })

    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          workspace = { checkThirdParty = false },
          completion = { callSnippet = "Replace" },
          hint = { enable = true, setType = false, paramType = true, paramName = "Disable" },
        },
      },
    })

    vim.lsp.enable({ "lua_ls" })

    -- ============================================================
    -- mason.nvim — LSP 服务器安装器
    -- ============================================================
    require("mason").setup({
      ensure_installed = {
        "lua-language-server",
      },
    })

    require("mason-lspconfig").setup({})

    vim.keymap.set("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "Mason 安装器" })
  end,
})
