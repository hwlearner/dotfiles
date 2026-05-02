vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.clipboard = "unnamedplus"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.wrap = false
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 8
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.timeoutlen = 300
vim.opt.updatetime = 200
vim.opt.termguicolors = true
vim.opt.inccommand = "split"
vim.opt.signcolumn = "yes:1"

vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>")

vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==")
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==")

local function vsc(cmd)
  return function()
    require("vscode").action(cmd)
  end
end

local function vsc_send(keys)
  return function()
    require("vscode-neovim").action("vscode-neovim.send", { args = keys })
  end
end

-- File
vim.keymap.set("n", "<leader>ff", vsc("workbench.action.quickOpen"), { desc = "Find Files" })
vim.keymap.set("n", "<leader>fF", vsc("workbench.action.findInFiles"), { desc = "Find in Files" })
vim.keymap.set("n", "<leader>fg", vsc("workbench.action.findInFiles"), { desc = "Live Grep" })
vim.keymap.set("n", "<leader>f/", vsc("actions.find"), { desc = "Find in Buffer" })
vim.keymap.set("n", "<leader>fr", vsc("workbench.action.openRecent"), { desc = "Recent Files" })
vim.keymap.set("n", "<leader>fs", vsc("workbench.action.files.save"), { desc = "Save File" })
vim.keymap.set("n", "<leader>fS", vsc("workbench.action.files.saveAll"), { desc = "Save All" })

-- Explorer
vim.keymap.set("n", "<leader>e", vsc("workbench.explorer.fileView.focus"), { desc = "Explorer" })
vim.keymap.set("n", "<leader>E", vsc("workbench.action.toggleSidebarVisibility"), { desc = "Toggle Sidebar" })
vim.keymap.set("n", "<leader>ea", vsc("explorer.newFile"), { desc = "New File" })
vim.keymap.set("n", "<leader>ed", vsc("explorer.newFolder"), { desc = "New Folder" })

-- Buffer
vim.keymap.set("n", "<leader>bd", vsc("workbench.action.closeActiveEditor"), { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>bD", vsc("workbench.action.closeOtherEditors"), { desc = "Close Others" })
vim.keymap.set("n", "<leader>bb", vsc("workbench.action.quickOpenPreviousEditor"), { desc = "Switch Buffer" })
vim.keymap.set("n", "<leader>bp", vsc("workbench.action.previousEditor"), { desc = "Previous Buffer" })
vim.keymap.set("n", "<leader>bn", vsc("workbench.action.nextEditor"), { desc = "Next Buffer" })
vim.keymap.set("n", "<leader>bf", vsc("workbench.action.quickOpenPreviousRecentlyUsedEditorInGroup"), { desc = "Recent Buffer" })

-- Window
vim.keymap.set("n", "<leader>wv", vsc("workbench.action.splitEditor"), { desc = "Split Vertical" })
vim.keymap.set("n", "<leader>wh", vsc("workbench.action.splitEditorOrthogonal"), { desc = "Split Horizontal" })
vim.keymap.set("n", "<leader>wc", vsc("workbench.action.closeEditorsInGroup"), { desc = "Close Split" })
vim.keymap.set("n", "<leader>ww", vsc("workbench.action.focusNextGroup"), { desc = "Next Window" })
vim.keymap.set("n", "<leader>wW", vsc("workbench.action.focusPreviousGroup"), { desc = "Prev Window" })
vim.keymap.set("n", "<leader>wo", vsc("workbench.action.joinAllGroups"), { desc = "Only Window" })
vim.keymap.set("n", "<leader>wm", vsc("workbench.action.toggleMaximizedPanel"), { desc = "Maximize" })

-- Code / LSP
vim.keymap.set("n", "<leader>ca", vsc("editor.action.quickFix"), { desc = "Code Action" })
vim.keymap.set("n", "<leader>cA", vsc("editor.action.sourceAction"), { desc = "Source Action" })
vim.keymap.set("n", "<leader>cr", vsc("editor.action.rename"), { desc = "Rename" })
vim.keymap.set("n", "<leader>cf", vsc("editor.action.formatDocument"), { desc = "Format Document" })
vim.keymap.set("n", "<leader>cF", vsc("editor.action.formatSelection"), { desc = "Format Selection" })
vim.keymap.set("n", "K", vsc("editor.action.showHover"), { desc = "Hover" })
vim.keymap.set("n", "<leader>ci", vsc("editor.action.organizeImports"), { desc = "Organize Imports" })

-- Go to (gd is built-in with vscode-neovim, but lets be explicit)
vim.keymap.set("n", "<leader>gd", vsc("editor.action.revealDefinition"), { desc = "Go to Definition" })
vim.keymap.set("n", "<leader>gD", vsc("editor.action.revealDeclaration"), { desc = "Go to Declaration" })
vim.keymap.set("n", "<leader>gi", vsc("editor.action.goToImplementation"), { desc = "Go to Implementation" })
vim.keymap.set("n", "<leader>gr", vsc("editor.action.referenceSearch.trigger"), { desc = "References" })
vim.keymap.set("n", "<leader>gt", vsc("editor.action.goToTypeDefinition"), { desc = "Go to Type" })
vim.keymap.set("n", "<leader>gs", vsc("workbench.action.gotoSymbol"), { desc = "Go to Symbol" })
vim.keymap.set("n", "<leader>gS", vsc("editor.action.quickOutline"), { desc = "Outline" })

-- Diagnostics
vim.keymap.set("n", "<leader>xx", vsc("workbench.actions.view.problems"), { desc = "Diagnostics" })
vim.keymap.set("n", "]d", vsc("editor.action.marker.next"), { desc = "Next Diagnostic" })
vim.keymap.set("n", "[d", vsc("editor.action.marker.prev"), { desc = "Prev Diagnostic" })
vim.keymap.set("n", "<leader>xd", vsc("editor.action.showHover"), { desc = "Diagnostic Detail" })

-- Git
vim.keymap.set("n", "<leader>gg", vsc("workbench.view.scm"), { desc = "Git (SCM)" })
vim.keymap.set("n", "<leader>gb", vsc("git.toggleBlame"), { desc = "Git Blame" })
vim.keymap.set("n", "<leader>gB", vsc("gitlens.toggleFileBlame"), { desc = "Git Blame (Lens)" })
vim.keymap.set("n", "<leader>gd", vsc("git.openChange"), { desc = "Git Diff" })
vim.keymap.set("n", "<leader>gc", vsc("git.commit"), { desc = "Git Commit" })
vim.keymap.set("n", "<leader>gp", vsc("git.push"), { desc = "Git Push" })
vim.keymap.set("n", "<leader>gl", vsc("git.pull"), { desc = "Git Pull" })

-- Terminal
vim.keymap.set("n", "<leader>ft", vsc("workbench.action.terminal.toggleTerminal"), { desc = "Toggle Terminal" })
vim.keymap.set("n", "<leader>fT", vsc("workbench.action.terminal.new"), { desc = "New Terminal" })
vim.keymap.set("n", "<leader>fj", vsc("workbench.action.terminal.focusNext"), { desc = "Next Terminal" })
vim.keymap.set("n", "<leader>fk", vsc("workbench.action.terminal.focusPrevious"), { desc = "Prev Terminal" })
vim.keymap.set("t", "<Esc><Esc>", vsc("workbench.action.terminal.focusPrevious"), { desc = "Focus Editor" })

-- Search
vim.keymap.set("n", "<leader>sr", vsc("workbench.action.replaceInFiles"), { desc = "Replace in Files" })
vim.keymap.set("n", "<leader>ss", vsc("workbench.action.gotoSymbol"), { desc = "Symbol Search" })

-- UI
vim.keymap.set("n", "<leader>ut", vsc("workbench.action.toggleStatusbarVisibility"), { desc = "Toggle Statusbar" })
vim.keymap.set("n", "<leader>ul", vsc("editor.action.toggleRenderWhitespace"), { desc = "Toggle Whitespace" })
vim.keymap.set("n", "<leader>uc", vsc("editor.action.toggleMinimap"), { desc = "Toggle Minimap" })
vim.keymap.set("n", "<leader>ub", vsc("editor.action.toggleBreadcrumbs"), { desc = "Toggle Breadcrumbs" })
vim.keymap.set("n", "<leader>uz", vsc("workbench.action.toggleZenMode"), { desc = "Zen Mode" })

-- Run / Debug
vim.keymap.set("n", "<leader>rr", vsc("workbench.action.debug.start"), { desc = "Run/Debug" })
vim.keymap.set("n", "<leader>rR", vsc("workbench.action.debug.run"), { desc = "Run Without Debugging" })
vim.keymap.set("n", "<leader>rc", vsc("workbench.action.debug.continue"), { desc = "Continue" })
vim.keymap.set("n", "<leader>ro", vsc("workbench.action.debug.stepOver"), { desc = "Step Over" })
vim.keymap.set("n", "<leader>ri", vsc("workbench.action.debug.stepInto"), { desc = "Step Into" })
vim.keymap.set("n", "<leader>rO", vsc("workbench.action.debug.stepOut"), { desc = "Step Out" })
vim.keymap.set("n", "<leader>rb", vsc("editor.debug.action.toggleBreakpoint"), { desc = "Toggle Breakpoint" })
vim.keymap.set("n", "<leader>rB", vsc("workbench.action.debug.toggleBreakpoint"), { desc = "Conditional Breakpoint" })

-- Quit / Window
vim.keymap.set("n", "<leader>qq", vsc("workbench.action.closeWindow"), { desc = "Quit" })
vim.keymap.set("n", "<leader>qr", vsc("workbench.action.reloadWindow"), { desc = "Reload Window" })
vim.keymap.set("n", "<leader>qp", vsc("workbench.action.closeFolder"), { desc = "Close Project" })

-- Markdown
vim.keymap.set("n", "<leader>mp", vsc("markdown.showPreview"), { desc = "Markdown Preview" })
vim.keymap.set("n", "<leader>mP", vsc("markdown.showPreviewToSide"), { desc = "Markdown Preview (Side)" })

-- C++ header/source switch
vim.keymap.set("n", "<leader>ch", vsc("C_Cpp.SwitchHeaderSource"), { desc = "Switch Header/Source (C++)" })

-- Settings
vim.keymap.set("n", "<leader>sk", vsc("workbench.action.openGlobalKeybindings"), { desc = "Keybindings" })
vim.keymap.set("n", "<leader>sS", vsc("workbench.action.openSettings"), { desc = "Settings" })
vim.keymap.set("n", "<leader>sc", vsc("workbench.action.openSettingsJson"), { desc = "Settings (JSON)" })

-- Search highlight: n/N navigate VS Code find matches with highlight
vim.keymap.set("n", "n", vsc("editor.action.nextMatchFindAction"), { desc = "Next Search Match" })
vim.keymap.set("n", "N", vsc("editor.action.previousMatchFindAction"), { desc = "Prev Search Match" })

-- Quickfix: navigate Problems panel
vim.keymap.set("n", "<leader>qj", vsc("workbench.action.problems.nextInFiles"), { desc = "Next Problem" })
vim.keymap.set("n", "<leader>qk", vsc("workbench.action.problems.previousInFiles"), { desc = "Prev Problem" })
vim.keymap.set("n", "<leader>ql", vsc("workbench.actions.view.problems"), { desc = "Problem List" })

-- Paste and auto-indent
vim.keymap.set("n", "<leader>=", function()
  require("vscode").action("editor.action.formatDocument")
end, { desc = "Format Document" })
vim.keymap.set("v", "=", vsc("editor.action.formatSelection"), { desc = "Format Selection" })

-- which-key: show leader key hints
vim.keymap.set("n", "<leader>?", function()
  local lines = {}
  local maps = vim.api.nvim_get_keymap("n")
  table.sort(maps, function(a, b) return a.lhs < b.lhs end)
  for _, m in ipairs(maps) do
    if m.lhs:sub(1, 1) == " " and m.lhs ~= " " and m.desc and m.desc ~= "" then
      local key = string.format("%-16s", m.lhs):sub(1, 16)
      table.insert(lines, key .. " " .. m.desc)
    end
  end
  if #lines > 0 then
    require("vscode").eval([[
      const msg = ]] .. vim.fn.json_encode(table.concat(lines, "\n")) .. [[;
      const result = window.showInformationMessage(msg, { modal: true }, 'OK');
    ]])
  end
end, { desc = "Show Keybindings" })
