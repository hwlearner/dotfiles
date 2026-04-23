
  export HOMEBREW_PIP_INDEX_URL=https://mirrors.cloud.tencent.com/pypi/simple #ckbrew
  export HOMEBREW_API_DOMAIN=https://mirrors.cloud.tencent.com/homebrew-bottles/api  #ckbrew
  export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.cloud.tencent.com/homebrew-bottles #ckbrew
  export RUSTUP_DIST_SERVER=https://rsproxy.cn #ckrust
  export RUSTUP_UPDATE_ROOT=https://rsproxy.cn/rustup #ckrust
  eval $(/opt/homebrew/bin/brew shellenv) #ckbrew
  export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH" #ckjava
  export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home" #ckjava

  export CANGJIE_HOME="$HOME/Developer/cangjie/current" #ckcangjie
  if [ -d "$CANGJIE_HOME/bin" ]; then
    export PATH="$CANGJIE_HOME/bin:$PATH" #ckcangjie
  fi

  export HARMONYOS_SDK_HOME="$HOME/Library/Huawei/Sdk/openharmony/23" #ckharmony
  if [ -d "$HARMONYOS_SDK_HOME/toolchains" ]; then
    export PATH="$HARMONYOS_SDK_HOME/toolchains:$PATH" #ckharmony
  fi

  export OHPM_HOME="$HOME/Library/Huawei/ohpm" #ckharmony
  if [ -d "$OHPM_HOME/bin" ]; then
    export PATH="$OHPM_HOME/bin:$PATH" #ckharmony
  fi
