return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bashls = { mason = false },
        jsonls = { mason = false },
        pyright = { mason = false },
        yamlls = { mason = false },
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      local remove = {
        ["bash-language-server"] = true,
        ["json-lsp"] = true,
        ["markdown-toc"] = true,
        ["markdownlint-cli2"] = true,
        ["pyright"] = true,
        ["yaml-language-server"] = true,
      }

      if type(opts.ensure_installed) == "table" then
        opts.ensure_installed = vim.tbl_filter(function(tool)
          return not remove[tool]
        end, opts.ensure_installed)
      end
    end,
  },
}
