local function external(cmd)
  local path = vim.fn.exepath(cmd)
  if path == "" then
    return false
  end

  local mason_bin = vim.fs.normalize(vim.fn.stdpath("data") .. "/mason/bin")
  return not vim.fs.normalize(path):find(mason_bin, 1, true)
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      if external("bash-language-server") then
        opts.servers.bashls = vim.tbl_deep_extend("force", opts.servers.bashls or {}, { mason = false })
      end
      if external("vscode-json-language-server") then
        opts.servers.jsonls = vim.tbl_deep_extend("force", opts.servers.jsonls or {}, { mason = false })
      end
      if external("pyright-langserver") then
        opts.servers.pyright = vim.tbl_deep_extend("force", opts.servers.pyright or {}, { mason = false })
      end
      if external("yaml-language-server") then
        opts.servers.yamlls = vim.tbl_deep_extend("force", opts.servers.yamlls or {}, { mason = false })
      end
    end,
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        local remove = {
          ["bash-language-server"] = external("bash-language-server"),
          ["json-lsp"] = external("vscode-json-language-server"),
          ["markdown-toc"] = external("markdown-toc"),
          ["markdownlint-cli2"] = external("markdownlint-cli2"),
          ["pyright"] = external("pyright-langserver"),
          ["yaml-language-server"] = external("yaml-language-server"),
        }

        opts.ensure_installed = vim.tbl_filter(function(tool)
          return not remove[tool]
        end, opts.ensure_installed)
      end
    end,
  },
}
