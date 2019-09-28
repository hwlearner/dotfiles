typeset -U path
path=(~/.local/bin ~/.cargo/bin $path)

export GDK_SCALE=2
export QT_AUTO_SCREEN_SCALE_FACTOR=2
export XDG_SESSION_TYPE=wayland
export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland-egl
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export _JAVA_AWT_WM_NONREPARENTING=1
