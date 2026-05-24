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
    fzf_base="/opt/homebrew/opt/fzf/shell"
    ;;
  *)
    fzf_base="/usr/share/fzf"
    ;;
esac

if [[ -o interactive && -t 0 && -t 1 && -r "$fzf_base/key-bindings.zsh" ]]; then
  source "$fzf_base/key-bindings.zsh"
fi
if [[ -o interactive && -t 0 && -t 1 && -r "$fzf_base/completion.zsh" ]]; then
  source "$fzf_base/completion.zsh"
fi
unset fzf_base

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
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
if command -v eza >/dev/null 2>&1; then
  alias ls="eza"
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
# fd + zf — 模糊搜索目录并跳转
# ==============================================================================
function j() {
    local dir
    dir=$(fd --type d --hidden --follow --exclude .git . "${1:-.}" 2>/dev/null | zf) && cd "$dir"
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
# mihomo 代理（检测到本地运行时自动启用，容器里不会设置）
if pgrep -x mihomo &>/dev/null; then
  export HTTP_PROXY=http://127.0.0.1:7890
  export HTTPS_PROXY=http://127.0.0.1:7890
  export NO_PROXY=localhost,127.0.0.1,.local,.lan,.pi,10.0.0.0/8
fi
