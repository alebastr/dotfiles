# My sway environment and configuration

The configuration is based on <https://gitlab.com/fedora/sigs/sway/sway-config-fedora>
and overrides it when necessary.

## Autostart
```
% cat ~/.config/sway/config.d/99-autostart.conf
# sleep 2 is a hack that gives waybar time to bind to org.kde.StatusNotifierHost
# eventually should be addressed with dbus activation
exec 'sleep 2; systemctl --user start xdg-desktop-autostart.target'
% cat ~/.config/systemd/user/xdg-desktop-autostart.target.d/override.conf
[Unit]
RefuseManualStart=no
```

## PolicyKit integration
Polkicy Kit agent is required to handle privilege escalation requests from apps like `gparted`, `virt-manager` and lots of others.
The app of my choice is [`lxqt-policykit`](https://github.com/lxqt/lxqt-policykit) as it has native wayland support and does not pull hundreds of dependencies. Two bits of configuration would be necessary for sway integration: window rules and autostart file that is working with sway.
```
% cat /usr/share/sway/config.d/50-rules-policykit-agent.conf
for_window [app_id="lxqt-policykit-agent"] {
    floating enable
    move position center
}
% cat ~/.config/autostart/lxqt-policykit-agent.desktop
[Desktop Entry]
Type=Application
Name=Policy Kit Handler
TryExec=/usr/libexec/lxqt-policykit-agent
Exec=/usr/libexec/lxqt-policykit-agent
OnlyShowIn=sway;
```

## Screenshots, screencasts, desktop portals, etc

### Installing:
* `xdg-desktop-portal-wlr` provides Screenshot and Screencast specific for wlroots-based compositors
* `xdg-desktop-portal-gtk` or `xdg-desktop-portal-kde` provides implementation for the rest of `xdg-desktop-portal`  interfaces: files, dialogs, settings, etc. Will be needed for a certain operations within flatpak sandboxed applications.

### Configuring:

<https://github.com/alebastr/sway-systemd> takes care of the necessary environment setup for XDG portals.

## Applications

**OS**: [Fedora](https://getfedora.org/)

**Browser**: Firefox + [Tridactyl](https://github.com/tridactyl/tridactyl)

**Terminal**: [foot](https://codeberg.org/dnkl/foot)

**Launcher**: [rofi-wayland](https://github.com/lbonn/rofi)

**Notifications**: [mako](https://github.com/emersion/mako) or [dunst](https://github.com/dunst-project/dunst)

**Panel**: [Waybar](https://github.com/Alexays/Waybar)

**Image viewer**: [imv](https://sr.ht/~exec64/imv/), [feh](https://github.com/derf/feh)

**Video**: mpv

**Network**: NetworkManager, `nm-applet --indicator`

**Bluetooth**: [blueman](https://github.com/blueman-project/blueman)
