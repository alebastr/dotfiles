# tmux aliases and cgroup wrappers for bash/zsh
# shellcheck shell=bash
#
if ! command -v tmux >/dev/null; then
    return 0
fi

if [ -n "$TMUX" ]; then
    # define function for refreshing environment from tmux
    function refresh-environment {
        eval "$(tmux show-environment -s | grep -v "^unset")"
    }
elif [ -n "$SSH_CONNECTION" ]; then
    # connect to tmux default session in remote shells
    tmux new -A -s default
fi

# check if systemd is running and required commands are available
if [ ! -d "$XDG_RUNTIME_DIR/systemd" ] ||
        ! command -v systemd-run >/dev/null ||
        ! command -v busctl > /dev/null; then
    return 0
fi

if [ -z "$TMUX" ]; then
    # start tmux in tmux-UUID.slice
    function tmux {
        local UUID
        UUID=$(uuidgen | tr -d '-')
        systemd-run --quiet --same-dir --user --scope \
            --slice "tmux-$UUID" --unit "tmux-$UUID"  \
            tmux "$@";
    }
else
    function get-current-unit {
        local CGROUP
        CGROUP=$(cat /proc/self/cgroup)
        basename "$CGROUP"
    }
    function get-current-slice {
        local CGROUP
        CGROUP=$(cat /proc/self/cgroup)
        while [[ -n $CGROUP && ! ($CGROUP =~ \.slice$) ]]; do
            CGROUP=$(dirname "$CGROUP")
        done
        basename "$CGROUP"
    }
    # create cgroup for a current shell
    function _ {
        if [[ ! -f /proc/self/cgroup ]]; then
            return
        fi
        local SD_SLICE
        local SD_UNIT
        SD_SLICE=$(get-current-slice)
        SD_UNIT=$(get-current-unit)
        if [[ $SD_UNIT =~ tmux-[A-Za-z0-9]*\.scope$ ]]; then
            SD_UNIT=${SD_SLICE/%.slice/-$$.scope}
            SD_UNIT=${SD_UNIT/tmux-/tmux-shell-}
            busctl call --user \
                org.freedesktop.systemd1 /org/freedesktop/systemd1  \
                org.freedesktop.systemd1.Manager StartTransientUnit \
                'ssa(sv)a(sa(sv))' "$SD_UNIT" fail 2 \
                PIDs au 1 $$      \
                Slice s "$SD_SLICE" \
                0 >/dev/null
        fi
    } && _ 2>/dev/null;
    unset -f _ get-current-unit get-current-slice;
fi
