export RUSTUP_DIST_SERVER=https://repo.huaweicloud.com/rust
export RUSTUP_UPDATE_ROOT=https://repo.huaweicloud.com/rust/rustup

case "$(uname -s)" in
  Darwin)
    export npm_config_registry=https://repo.huaweicloud.com/repository/npm/

    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    if [ -d /opt/homebrew/opt/openjdk@17 ]; then
      export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
      export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
    fi

    if [ -d "$HOME/Developer/cangjie/current/bin" ]; then
      export CANGJIE_HOME="$HOME/Developer/cangjie/current"
      export PATH="$CANGJIE_HOME/bin:$PATH"
    fi

    if [ -d "$HOME/Library/Huawei/Sdk/openharmony/23/toolchains" ]; then
      export HARMONYOS_SDK_HOME="$HOME/Library/Huawei/Sdk/openharmony/23"
      export PATH="$HARMONYOS_SDK_HOME/toolchains:$PATH"
    fi

    if [ -d "$HOME/Library/Huawei/ohpm/bin" ]; then
      export OHPM_HOME="$HOME/Library/Huawei/ohpm"
      export PATH="$OHPM_HOME/bin:$PATH"
    fi
    ;;

  Linux)
    # Linux 专用环境变量放这里
    # PATH 已在 .zshenv 中统一管理
    ;;
esac

if [[ -r "$HOME/.zprofile.local" ]]; then
  source "$HOME/.zprofile.local"
fi
