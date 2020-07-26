export PATH="$HOME/bin:${PATH/:$HOME\/bin/}"

export DOTNET_CLI_TELEMETRY_OPTOUT=1
export CALIBRE_USE_SYSTEM_THEME=1
# https://mastransky.wordpress.com/2020/03/16/wayland-x11-how-to-run-firefox-in-mixed-environment/
export MOZ_DBUS_REMOTE=1

if [[ $DESKTOP_SESSION =~ "sway" ]]; then
    export MOZ_ENABLE_WAYLAND=1
    export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
    export QT_WAYLAND_FORCE_DPI=96
    export QT_QPA_PLATFORMTHEME=qt5ct
    # required for xdg-desktop-portal backend selection
    export XDG_CURRENT_DESKTOP=sway
    export XDG_SESSION_TYPE=wayland
fi
