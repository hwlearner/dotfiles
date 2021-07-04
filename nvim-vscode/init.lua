vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"

local is_windows = vim.fn.has("win32") == 1
local is_mac = vim.fn.has("macunix") == 1

if is_windows then
  vim.opt.shell = "pwsh"
elseif is_mac then
  vim.opt.shell = "zsh"
end

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

if vim.g.vscode then
  local vscode = require("vscode")

  -- Reduce routine Vim chatter that vscode-neovim forwards to the messages output.
  vim.opt.incsearch = false
  vim.opt.showmode = false
  vim.opt.showcmd = false
  vim.opt.ruler = false
  vim.opt.report = 9999
  vim.opt.shortmess:append("s")
  vim.opt.shortmess:append("S")
  vim.opt.shortmess:append("I")
  vim.opt.shortmess:append("W")
  vim.opt.shortmess:append("c")

  local function silent_vim_search(direction)
    return function()
      local pattern = vim.fn.getreg("/")
      if pattern == nil or pattern == "" then
        return
      end

      pcall(vim.cmd, ("silent! normal! %s"):format(direction))
    end
  end

  keymap("n", "<leader>w", "<cmd>w<cr>", opts)
  keymap("n", "<leader>q", "<cmd>q<cr>", opts)
  keymap("n", "n", silent_vim_search("n"), opts)
  keymap("n", "N", silent_vim_search("N"), opts)

  keymap("n", "<leader>ff", function()
    vscode.action("workbench.action.quickOpen")
  end, opts)

  keymap("n", "<leader>fg", function()
    vscode.action("workbench.action.findInFiles")
  end, opts)

  keymap("n", "<leader>fr", function()
    vscode.action("workbench.action.openRecent")
  end, opts)

  keymap("n", "<leader>bb", function()
    vscode.action("workbench.action.showAllEditors")
  end, opts)

  keymap("n", "<leader>bd", function()
    vscode.action("workbench.action.closeActiveEditor")
  end, opts)

  keymap("n", "<leader>e", function()
    vscode.action("workbench.view.explorer")
  end, opts)

  keymap("n", "<leader>gs", function()
    vscode.action("workbench.view.scm")
  end, opts)

  keymap("n", "<leader>xx", function()
    vscode.action("workbench.actions.view.problems")
  end, opts)

  keymap("n", "<leader>ca", function()
    vscode.action("editor.action.codeAction")
  end, opts)

  keymap("n", "<leader>rn", function()
    vscode.action("editor.action.rename")
  end, opts)

  keymap("n", "gd", function()
    vscode.action("editor.action.revealDefinition")
  end, opts)

  keymap("n", "gr", function()
    vscode.action("editor.action.goToReferences")
  end, opts)

  keymap("n", "K", function()
    vscode.action("editor.action.showHover")
  end, opts)

  keymap("n", "<leader>sv", function()
    vscode.action("workbench.action.splitEditorRight")
  end, opts)

  keymap("n", "<leader>sh", function()
    vscode.action("workbench.action.splitEditorDown")
  end, opts)

  keymap("n", "<leader>1", function()
    vscode.action("workbench.action.focusFirstEditorGroup")
  end, opts)

  keymap("n", "<leader>2", function()
    vscode.action("workbench.action.focusSecondEditorGroup")
  end, opts)

  keymap("n", "<leader>3", function()
    vscode.action("workbench.action.focusThirdEditorGroup")
  end, opts)

  keymap("n", "<leader>4", function()
    vscode.action("workbench.action.focusFourthEditorGroup")
  end, opts)

  keymap("n", "<leader>h", function()
    vscode.action("workbench.action.focusLeftGroup")
  end, opts)

  keymap("n", "<leader>j", function()
    vscode.action("workbench.action.focusBelowGroup")
  end, opts)

  keymap("n", "<leader>k", function()
    vscode.action("workbench.action.focusAboveGroup")
  end, opts)

  keymap("n", "<leader>l", function()
    vscode.action("workbench.action.focusRightGroup")
  end, opts)

  keymap("n", "<leader>/", function()
    vscode.action("workbench.action.findInFiles")
  end, opts)

  keymap("n", "<leader>mp", function()
    vscode.action("markdown.showPreviewToSide")
  end, opts)

  keymap("n", "<leader>mo", function()
    vscode.action("markdown.showSource")
  end, opts)

  keymap("n", "<leader>mz", function()
    vscode.action("workbench.action.toggleZenMode")
  end, opts)
end
