#!/bin/bash

export MOZ_ENABLE_WAYLAND=1
export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
export QT_WAYLAND_FORCE_DPI=96
export QT_QPA_PLATFORMTHEME=qt5ct
# required for xdg-desktop-portal backend selection
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_DESKTOP=sway
export XDG_SESSION_TYPE=wayland

exec /bin/systemd-cat "/usr/bin/$(basename "$0")" "$@"
