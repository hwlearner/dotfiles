alias vi=nvim
alias ls=lsd

source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export PATH="$HOME/.local/bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

__conda_setup="$('/home/sc/.local/conda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/sc/.local/conda3/etc/profile.d/conda.sh" ]; then
        . "/home/sc/.local/conda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/sc/.local/conda3/bin:$PATH"
    fi
fi
unset __conda_setup

eval "$(starship init zsh)"
