#!/bin/sh
exec flatpak run \
    --runtime=org.kde.Platform --runtime-version=5.15 \
    com.calibre_ebook.calibre "$@"
