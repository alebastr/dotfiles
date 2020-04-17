export DOTNET_CLI_TELEMETRY_OPTOUT=1
# no longer needed as of libva-2.7.1-4.fc32/libva-2.7.2
#export LIBVA_DRIVER_NAME=iHD

export PATH="$HOME/bin:${PATH/:$HOME\/bin/}"

if [[ $DESKTOP_SESSION =~ "sway" ]]; then
    export CALIBRE_USE_SYSTEM_THEME=1
    # https://mastransky.wordpress.com/2020/03/16/wayland-x11-how-to-run-firefox-in-mixed-environment/
    export MOZ_DBUS_REMOTE=1
    export MOZ_ENABLE_WAYLAND=1
    export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
    export QT_WAYLAND_FORCE_DPI=96
    # required for xdg-desktop-portal backend selection
    export XDG_CURRENT_DESKTOP=sway
fi
