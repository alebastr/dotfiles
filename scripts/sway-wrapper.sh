#!/bin/bash

export MOZ_ENABLE_WAYLAND=1
export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
export QT_WAYLAND_FORCE_DPI=96
export QT_QPA_PLATFORMTHEME=qt5ct
# required for xdg-desktop-portal backend selection
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_DESKTOP=sway
export XDG_SESSION_TYPE=wayland

# redirect errors to a file in user's home directory if we can
#errfile="$HOME/.xsession-errors"
#if ( umask 077 && cp /dev/null "$errfile" 2> /dev/null ); then
#    chmod 600 "$errfile"
#    [ -x /sbin/restorecon ] && /sbin/restorecon $errfile
#    exec > "$errfile" 2>&1
#else
#    errfile=$(mktemp -q /tmp/xses-$USER.XXXXXX)
#    if [ $? -eq 0 ]; then
#        exec > "$errfile" 2>&1
#    fi
#fi

/bin/systemd-cat "/usr/bin/$(basename "$0")" "$@"
# stop systemd user services
/usr/bin/systemctl --user stop graphical-session.target graphical-session-pre.target
