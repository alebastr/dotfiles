# tmux aliases and cgroup wrappers for bash/zsh
if command -v tmux >/dev/null; then
    # start tmux in tmux-UUID.slice
    if command -v systemd-run >/dev/null; then
        function tmux {
            local UUID=`uuidgen | sed s/\-//g`;
            systemd-run --quiet --same-dir --user --scope \
                --slice tmux-$UUID --unit tmux-$UUID      \
                tmux "$@";
        }
    fi
    # connect to tmux default session in remote shells
    if [[ -n "$SSH_CONNECTION" && -z "$TMUX" ]]; then
        tmux new -A -s default
    fi
fi

if [ -n "$TMUX" ]; then
    # define function for refreshing environment from tmux
    function refresh-environment {
        tmux show-environment -s | grep -v "^unset" | source /dev/stdin
    }
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
else
    function refresh-environment { true; }
fi
