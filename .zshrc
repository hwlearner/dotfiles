export EDITOR=nvim
export VISUAL=nvim
export PAGER=less

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt append_history share_history hist_ignore_dups hist_ignore_space extended_glob auto_cd

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

if [[ -r "$fzf_base/key-bindings.zsh" ]]; then
  source "$fzf_base/key-bindings.zsh"
fi
if [[ -r "$fzf_base/completion.zsh" ]]; then
  source "$fzf_base/completion.zsh"
fi
unset fzf_base

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
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

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
