typeset -U path PATH
path=("$HOME/.bun/bin" "$HOME/.local/bin" "$HOME/.cargo/bin" $path)



if [[ -d "$HOME/.local/share/nvim/mason/bin" ]]; then
  path=($path "$HOME/.local/share/nvim/mason/bin")
fi

if [[ -d "$HOME/.local/opt/cangjie/current" ]]; then
  export CANGJIE_HOME="$HOME/.local/opt/cangjie/current"
  path=("$HOME/.cjpm/bin" $path)
fi

if [[ -r "$HOME/.zshenv.local" ]]; then
  source "$HOME/.zshenv.local"
fi

export PATH
