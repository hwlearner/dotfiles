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

      if external("clangd") then
        opts.servers.clangd = vim.tbl_deep_extend("force", opts.servers.clangd or {}, { mason = false })
      end
      if external("marksman") then
        opts.servers.marksman = vim.tbl_deep_extend("force", opts.servers.marksman or {}, { mason = false })
      end
      if external("ruff") then
        opts.servers.ruff = vim.tbl_deep_extend("force", opts.servers.ruff or {}, { mason = false })
      end
    end,
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        local remove = {
          ["clang-format"] = external("clang-format"),
          ["markdownlint-cli2"] = external("markdownlint-cli2"),
          ["shellcheck"] = external("shellcheck"),
        }

        opts.ensure_installed = vim.tbl_filter(function(tool)
          return not remove[tool]
        end, opts.ensure_installed)
      end
    end,
  },
}
