export RUSTUP_DIST_SERVER=https://repo.huaweicloud.com/rust
export RUSTUP_UPDATE_ROOT=https://repo.huaweicloud.com/rust/rustup

if [[ -d "$HOME/.local/opt/cangjie/current/bin" ]]; then
  export CANGJIE_HOME="$HOME/.local/opt/cangjie/current"
  export PATH="$CANGJIE_HOME/bin:$PATH"
fi

if [[ -r "$HOME/.zprofile.local" ]]; then
  source "$HOME/.zprofile.local"
fi
