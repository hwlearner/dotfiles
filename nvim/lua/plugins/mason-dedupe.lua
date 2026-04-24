return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = { mason = false },
        marksman = { mason = false },
        ruff = { mason = false },
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      local remove = {
        ["clang-format"] = true,
        ["markdownlint-cli2"] = true,
        ["shellcheck"] = true,
      }

      if type(opts.ensure_installed) == "table" then
        opts.ensure_installed = vim.tbl_filter(function(tool)
          return not remove[tool]
        end, opts.ensure_installed)
      end
    end,
  },
}
