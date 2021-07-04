return {
  {
    "folke/tokyonight.nvim",
    optional = true,
    opts = {
      transparent = true,
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    optional = true,
    opts = {
      transparent_background = true,
      float = {
        transparent = true,
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      opts.colorscheme = opts.colorscheme or "tokyonight"

      local transparent_groups = {
        "Normal",
        "NormalNC",
        "NormalFloat",
        "FloatBorder",
        "SignColumn",
        "EndOfBuffer",
        "FoldColumn",
        "MsgArea",
      }

      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          for _, group in ipairs(transparent_groups) do
            vim.api.nvim_set_hl(0, group, { bg = "none" })
          end
        end,
      })
    end,
  },
}
