# Prompt Customization
POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR='\uf105'
POWERLEVEL9K_SHORTEN_DIR_LENGTH=3
POWERLEVEL9K_SHORTEN_STRATEGY='truncate_middle'
POWERLEVEL9K_VCS_CLEAN_FOREGROUND='green'
POWERLEVEL9K_VCS_CLEAN_BACKGROUND='none'
POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='yellow'
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='none'
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='red'
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='none'
POWERLEVEL9K_DIR_HOME_BACKGROUND='none'
POWERLEVEL9K_DIR_HOME_FOREGROUND='blue'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='none'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND='blue'
POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='none'
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND='magenta'
POWERLEVEL9K_ROOT_INDICATOR_BACKGROUND='red'
POWERLEVEL9K_ROOT_INDICATOR_FOREGROUND='white'
POWERLEVEL9K_STATUS_OK_BACKGROUND='none'
POWERLEVEL9K_STATUS_OK_FOREGROUND='green'
POWERLEVEL9K_STATUS_ERROR_BACKGROUND='none'
POWERLEVEL9K_STATUS_ERROR_FOREGROUND='red'
POWERLEVEL9K_STATUS_VERBOSE='false'
POWERLEVEL9K_VI_INSERT_MODE_STRING='令'
POWERLEVEL9K_VI_COMMAND_MODE_STRING='改'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(background_jobs dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(vi_mode)

# FZF Customization
export FZF_DEFAULT_OPTS='
  --color fg:7,hl:4,fg+:7,bg+:0,hl+:6
  --color info:8,prompt:4,spinner:4,pointer:6,marker:3
'

# Load zsh plugins
source $HOME/.config/antibody/plugins.sh

# Setting up autocompletion
autoload -Uz compinit
compinit

# case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

###########################################################
# => Vi keybindings
###########################################################

# Updates editor information when the keymap changes.
function zle-keymap-select() {
  zle reset-prompt
  zle -R
}

# Ensure that the prompt is redrawn when the terminal size changes.
TRAPWINCH() {
  zle &&  zle -R
}

zle -N zle-keymap-select
zle -N edit-command-line

bindkey -v

# allow v to edit the command line (standard behaviour)
autoload -Uz edit-command-line
bindkey -M vicmd 'v' edit-command-line

# allow ctrl-p, ctrl-n for navigate history (standard behaviour)
bindkey '^P' up-history
bindkey '^N' down-history

# allow ctrl-h, ctrl-w, ctrl-? for char and word deletion (standard behaviour)
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word

# allow ctrl-r to perform backward search in history
bindkey '^r' history-incremental-search-backward

# allow ctrl-a and ctrl-e to move to beginning/end of line
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

###########################################################
# => Functions
###########################################################

# Quick search and change directory
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# Quick search command history
fh() {
  eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# Quick navigate through directories
function ranger-cd {
    tempfile="$(mktemp -t tmp.XXXXXX)"
    ranger --choosedir="$tempfile" "${@:-$(pwd)}"
    test -f "$tempfile" &&
    if [ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]; then
        cd -- "$(cat "$tempfile")"
    fi
    rm -f -- "$tempfile"
}

###########################################################
# => Aliases
###########################################################

# Shortcuts
alias ls="exa"
alias rcd="ranger-cd"
alias gdb="gdb --quiet"
alias ts="transmission-daemon"
alias code="visual-studio-code"
alias tsr="transmission-remote-cli"
alias mmb="sudo ~/Projects/apfs-fuse/build/apfs-fuse -o uid=han,gid=han,allow_other /dev/sdb2 ~/MyBook"
# Configurations
alias zshconfig="nvim ~/.zshrc"
alias tmuxconfig="nvim ~/.tmux.conf"
alias nvimconfig="nvim ~/.config/nvim/init.vim"
