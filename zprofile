export DOTNET_CLI_TELEMETRY_OPTOUT=1

export PATH="$HOME/bin:${PATH/:$HOME\/bin/}"

if [[ $DESKTOP_SESSION =~ "sway" ]]; then
    export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
    export QT_WAYLAND_FORCE_DPI=96
    export XDG_CURRENT_DESKTOP=Unity
fi
