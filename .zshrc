export EDITOR=nvim
export VISUAL=nvim
export PAGER=less

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt append_history share_history hist_ignore_dups hist_ignore_space extended_glob auto_cd

autoload -Uz compinit
compinit

if [[ -r /usr/share/fzf/key-bindings.zsh ]]; then
  source /usr/share/fzf/key-bindings.zsh
fi
if [[ -r /usr/share/fzf/completion.zsh ]]; then
  source /usr/share/fzf/completion.zsh
fi

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

alias vi=nvim
alias ls="eza --icons=auto"
alias ll="eza -lah --git --icons=auto"
alias la="eza -la --git --icons=auto"
alias cat="bat --paging=never"
alias grep="grep --color=auto"

eval "$(starship init zsh)"
