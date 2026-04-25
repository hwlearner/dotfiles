export RUSTUP_DIST_SERVER=https://rsproxy.cn #ckrust
export RUSTUP_UPDATE_ROOT=https://rsproxy.cn/rustup #ckrust

case "$(uname -s)" in
  Darwin)
  export HOMEBREW_PIP_INDEX_URL=https://mirrors.cloud.tencent.com/pypi/simple #ckbrew
  export HOMEBREW_API_DOMAIN=https://mirrors.cloud.tencent.com/homebrew-bottles/api #ckbrew
  export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.cloud.tencent.com/homebrew-bottles #ckbrew
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)" #ckbrew
  fi
  if [ -d /opt/homebrew/opt/openjdk@17 ]; then
    export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH" #ckjava
    export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home" #ckjava
  fi

  if [ -d "$HOME/Developer/cangjie/current/bin" ]; then
    export CANGJIE_HOME="$HOME/Developer/cangjie/current" #ckcangjie
    export PATH="$CANGJIE_HOME/bin:$PATH" #ckcangjie
  fi

  if [ -d "$HOME/Library/Huawei/Sdk/openharmony/23/toolchains" ]; then
    export HARMONYOS_SDK_HOME="$HOME/Library/Huawei/Sdk/openharmony/23" #ckharmony
    export PATH="$HARMONYOS_SDK_HOME/toolchains:$PATH" #ckharmony
  fi

  if [ -d "$HOME/Library/Huawei/ohpm/bin" ]; then
    export OHPM_HOME="$HOME/Library/Huawei/ohpm" #ckharmony
    export PATH="$OHPM_HOME/bin:$PATH" #ckharmony
  fi
  ;;
  Linux)
  # Gentoo's /etc/zsh/zprofile reloads PATH from /etc/profile.env for login shells,
  # so re-apply user-level PATH entries here.
  typeset -U path PATH
  path=("$HOME/.local/bin" "$HOME/.cargo/bin" $path)
  if [[ -d "$HOME/.local/share/nvim/mason/bin" ]]; then
    path=($path "$HOME/.local/share/nvim/mason/bin")
  fi

  if [[ -d "$HOME/.local/opt/cangjie/current" ]]; then
    export CANGJIE_HOME="$HOME/.local/opt/cangjie/current"
    path=("$HOME/.cjpm/bin" $path)
  fi
  export PATH
  ;;
esac

if [[ -r "$HOME/.zprofile.local" ]]; then
  source "$HOME/.zprofile.local"
fi
