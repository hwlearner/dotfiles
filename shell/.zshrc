export EDITOR=nvim
export VISUAL=nvim
export PAGER=less
export OPENSPEC_TELEMETRY=0


HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt append_history share_history hist_ignore_dups hist_ignore_space extended_glob

autoload -Uz compinit
compinit -d "${ZSH_COMPDUMP:-$HOME/.zcompdump}"

case "$(uname -s)" in
  Darwin)
    sk_base="/opt/homebrew/opt/skim/shell"
    ;;
  *)
    sk_base="/usr/share/skim"
    ;;
esac

if [[ -o interactive && -t 0 && -t 1 && -r "$sk_base/key-bindings.zsh" ]]; then
  source "$sk_base/key-bindings.zsh"
fi
if [[ -o interactive && -t 0 && -t 1 && -r "$sk_base/completion.zsh" ]]; then
  source "$sk_base/completion.zsh"
fi
unset sk_base

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
alias vi=nvim
if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons=auto"
  alias ll="eza -lah --git --icons=auto"
  alias la="eza -la --git --icons=auto"
fi
if command -v bat >/dev/null 2>&1; then
  alias cat="bat --paging=never"
fi
alias grep="grep --color=auto"

if [[ -r "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi

if [[ -r "$HOME/.cargo/env" ]]; then
  source "$HOME/.cargo/env"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# opencode (Linux only — macOS uses Homebrew path from .zprofile)
if [[ "$(uname -s)" != "Darwin" && -d "$HOME/.opencode/bin" ]]; then
  export PATH="$HOME/.opencode/bin:$PATH"
fi

# ==============================================================================
# j — zoxide 交互式目录跳转
# ==============================================================================
function j() {
    zi
}

# ==============================================================================
# yazi — 终端文件管理器，退出后 cd 到所在目录
# ==============================================================================
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}
# 容器自动跳转到 workspace
if [[ -d /workspace ]]; then
  cd /workspace
fi

# bun completions
[ -s "/home/han/.bun/_bun" ] && source "/home/han/.bun/_bun"
