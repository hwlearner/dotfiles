# dotfiles

Configuration files for my macOS workflow.

## Layout

- `.zshrc`, `.zprofile`, `.tmux.conf`, `.gitconfig`: shell, tmux, and git basics.
- `.aerospace.toml`: AeroSpace window manager config.
- `.markdownlint.yaml`: shared markdownlint rules.
- `nvim/`: Neovim config from `~/.config/nvim`.
- `nvim-vscode/`: VS Code Neovim bridge config from `~/.config/nvim-vscode`.
- `ghostty/`: Ghostty config from `~/.config/ghostty`.
- `hammerspoon/`: Hammerspoon automation from `~/.hammerspoon`.
- `git/ignore`: global git ignore from `~/.config/git/ignore`.
- `vscode/`: VS Code user settings, keybindings, locale, and extension list.
- `autoconfig.yml`, `quickmarks`: older qutebrowser configs retained in the repo.

## Not tracked

Machine state, caches, histories, SSH keys, app tokens, VS Code global storage, and downloaded plugin directories should stay out of this repo.

## Windows VS Code sync

After cloning this repo on Windows, run `scripts\sync-vscode-windows.cmd` to copy the tracked VS Code config into your Windows user profile and install the listed extensions when the VS Code CLI is available.

What it syncs:

- `vscode/User/settings.json`, `keybindings.json`, `locale.json`
- `nvim-vscode/init.lua` to `%USERPROFILE%\.config\nvim-vscode\init.lua`
- `.markdownlint.yaml` to `%USERPROFILE%\.markdownlint.yaml`
- `vscode/extensions.txt` via `code --install-extension` when the VS Code CLI is available

Useful options:

- `scripts\sync-vscode-windows.cmd -WhatIf`: preview changes without writing files
- `scripts\sync-vscode-windows.cmd -InstallExtensions`: install extensions when passing other options
- `scripts\sync-vscode-windows.cmd -CangjieHome D:\Developer\cangjie\current`: override the default Cangjie SDK path
- `scripts\sync-vscode-windows.cmd -NeovimPath "D:\Tools\Neovim\bin\nvim.exe"`: override the default Neovim path
