--[[
=============================================================================
  lsp.lua — LSP（语言服务器协议）客户端
=============================================================================
  组件说明：
  - nvim-lspconfig       → 提供各语言 LSP 的配置预设
  - mason.nvim           → 在系统上安装 LSP 服务器/格式化器/linter
  - mason-lspconfig.nvim → 搭桥：告诉 lspconfig 哪些服务器已被 mason 安装

  后续可添加的补全引擎（不在本最小配置内）：
  - blink.cmp（推荐）或 nvim-cmp + nvim-cmp-lsp
=============================================================================
]]

return {
  -- ============================================================
  -- nvim-lspconfig — LSP 客户端预设
  -- ============================================================
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      { "mason-org/mason-lspconfig.nvim", config = function() end },
    },

    opts = {
      -- 诊断显示
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
        severity_sort = true,
      },
      -- LSP 服务器配置
      servers = {
        -- 通用 LSP 配置（按键在 LspAttach 中设置）
        ["*"] = {
          capabilities = {
            workspace = {
              fileOperations = {
                didRename = true,
                willRename = true,
              },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              completion = { callSnippet = "Replace" },
              hint = { enable = true, setType = false, paramType = true, paramName = "Disable" },
            },
          },
        },
        -- 按需启用更多服务器，例如：
        -- pyright = {},
        -- ts_ls = {},
        -- rust_analyzer = {},
        -- gopls = {},
      },
    },

    config = function(_, opts)
      -- LSP 附加时设置按键映射（已注册到对应 buffer）
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
        callback = function(ev)
          local buf = ev.buf
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client then return end

          -- 判断服务器是否有某个能力
          local has = function(cap)
            return client.server_capabilities[cap .. "Provider"] ~= nil
                or client.server_capabilities[cap] ~= nil
          end
          -- 启用内置 LSP 补全（自动弹出候选列表）
          -- 前提：服务器支持 textDocument/completion
          -- 选择确认用 <C-y>，取消用 <C-e>
          if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })
          end

          -- 格式化：LSP 优先
          vim.keymap.set("n", "<leader>cf", function()
            vim.lsp.buf.format({ async = false, bufnr = buf })
          end, { buffer = buf, desc = "格式化" })

          -- 通用 LSP 按键（按能力按需注册）
          local sk = function(lhs, rhs, desc, cap)
            if not cap or has(cap) then
              vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc, silent = true })
            end
          end
          sk("K", vim.lsp.buf.hover, "悬停文档")
          sk("gd", vim.lsp.buf.definition, "跳转定义", "definition")
          sk("gr", vim.lsp.buf.references, "查找引用", "references")
          sk("gI", vim.lsp.buf.implementation, "跳转实现", "implementation")
          sk("gy", vim.lsp.buf.type_definition, "跳转类型定义", "typeDefinition")
          sk("<leader>ca", vim.lsp.buf.code_action, "代码操作", "codeAction")
          sk("<leader>cr", vim.lsp.buf.rename, "重命名", "rename")
          sk("<leader>cd", vim.diagnostic.open_float, "行诊断")
          sk("]d", function() vim.diagnostic.jump({ count = 1 }) end, "下一诊断")
          sk("[d", function() vim.diagnostic.jump({ count = -1 }) end, "上一诊断")
        end,
      })

      -- 设置诊断显示
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- 配置并启用 LSP 服务器（Neovim 0.11+ 新 API）
      -- nvim-lspconfig 通过 vim.lsp.config 注册默认配置
      -- 我们只需对有自定义设置的服务器覆盖配置，然后启用

      -- 先设置所有服务器的通用能力
      if opts.servers["*"] then
        vim.lsp.config("*", opts.servers["*"])
      end

      -- 逐个应用自定义配置并启用
      local servers = vim.tbl_keys(opts.servers)
      local to_enable = {}
      for _, server in ipairs(servers) do
        if server ~= "*" then
          local sopts = opts.servers[server]
          if sopts ~= false then
            vim.lsp.config(server, sopts == true and {} or sopts)
            to_enable[#to_enable + 1] = server
          end
        end
      end
      vim.lsp.enable(to_enable)
    end,
  },

  -- ============================================================
  -- mason.nvim — LSP 服务器安装器
  -- ============================================================
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason 安装器" } },
    build = ":MasonUpdate",

    opts = {
      ensure_installed = {
        "lua-language-server",  -- Lua
        -- 按需取消注释：
        -- "pyright",           -- Python
        -- "typescript-language-server",  -- TypeScript/JavaScript
        -- "rust-analyzer",      -- Rust
        -- "gopls",              -- Go
        -- "clangd",             -- C/C++
      },
    },
  },
}
