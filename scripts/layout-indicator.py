#!/usr/bin/python3
import i3ipc
import json
import sys

short = {
    "splitv": "V",
    "splith": "H",
    "tabbed": "T",
    "stacked": "S",
}
last = ""


def write(text, tooltip=""):
    output = {"text": text, "tooltip": tooltip, "class": tooltip}
    sys.stdout.write(json.dumps(output) + "\n")
    sys.stdout.flush()


def on_event(self, _):
    global last
    focused = i3.get_tree().find_focused()
    if focused is None or focused.parent is None:
        return
    layout = focused.parent.layout
    if layout != last:
        write(short.get(layout, " "), layout)
    last = layout


i3 = i3ipc.Connection()

# Subscribe to events
i3.on("window::focus", on_event)
i3.on("binding", on_event)

write("?")
# Start the main loop and wait for events to come in.
i3.main()
