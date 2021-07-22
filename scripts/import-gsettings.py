#!/usr/bin/python3
"""
Usage: import-gsettings
URL: https://gist.github.com/mcepl/0d5564dbf085c45adcb93b3498a3153d
"""

import configparser
import os
import os.path

from gi import require_version

require_version("Gio", "2.0")
# pylint: disable=wrong-import-position
from gi.repository import Gio

translate_keys = {
    "gtk-theme-name": "gtk-theme",
    "gtk-icon-theme-name": "icon-theme",
    "gtk-cursor-theme-name": "cursor-theme",
    "gtk-font-name": "font-name",
    "monospace-font-name": "monospace-font-name",
}

config = configparser.ConfigParser()
config.read(
    [
        os.path.expandvars("$XDG_CONFIG_HOME/gtk-3.0/settings.ini"),
        os.path.expanduser("~/.config/gtk-3.0/settings.ini"),
    ]
)

sect = config["Settings"]

iface = Gio.Settings.new("org.gnome.desktop.interface")

for key in translate_keys:
    if key in sect:
        iface.set_string(translate_keys[key], sect[key])
