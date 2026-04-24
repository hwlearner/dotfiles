typeset -U path PATH
path=("$HOME/.local/bin" "$HOME/.cargo/bin" $path "$HOME/.local/share/nvim/mason/bin")

if [[ -d "$HOME/.local/opt/cangjie/current" ]]; then
  export CANGJIE_HOME="$HOME/.local/opt/cangjie/current"
  path=("$HOME/.cjpm/bin" $path)
fi

export PATH
