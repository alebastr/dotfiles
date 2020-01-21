#!/bin/bash
run() {
	local delay="0.1s"
	if [[ "$1" =~ ^[0-9\.]+[smhd]?$ ]]; then
		delay=$1; shift
	fi
	if ! pidof $1 >/dev/null; then
		(sleep $delay && exec $@) &
	fi
}

# ssh-agent
run gpg-connect-agent /bye

# xembed tray -> SNI translation
run 1 xembedsniproxy
