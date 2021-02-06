# My sway environment and configuration

## Autostart
```
% cat ~/.config/sway/config.d/99-dex-autostart.conf
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
% cat ~/.config/sway/config.d/60-windows-lxqt-policykit-agent.conf
for_window[app_id="lxqt-policykit-agent"] {
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
* `export XDG_CURRENT_DESKTOP=sway`  before starting sway. Generally it's enough to add the line with variable into `~/.bash_profile`, `~/.zprofile` , `~/.profile` , or whatever else works for your login shell.
* Update dbus and systemd environment variables:
  ```sh
  % cat /etc/sway/config.d/10-systemd.conf
  # Import minimal required environment for dbus and systemd user services
  # Set XDG_CURRENT_DESKTOP to "sway" for xdg-desktop-portal service
  exec hash dbus-update-activation-environment 2>/dev/null && \
       dbus-update-activation-environment --systemd DISPLAY SWAYSOCK WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
  exec export XDG_CURRENT_DESKTOP=sway && \
       systemctl --user import-environment DISPLAY SWAYSOCK WAYLAND_DISPLAY XDG_CURRENT_DESKTOP && \
       systemctl --user start sway-session.target
  ```
### Zoom, electron, etc...
<https://gitlab.com/jamedjo/gnome-dbus-emulation-wlr/> (not tested)

## Applications

**OS**: [Fedora](https://getfedora.org/)

**Browser**: Firefox + Tridactyl

**Terminal**: [alacritty](https://github.com/alacritty/alacritty) or [foot](https://codeberg.org/dnkl/foot)

**Launcher**: [rofi-wayland](https://github.com/lbonn/rofi)

**Notifications**: [mako](https://github.com/emersion/mako)

**Panel**: [Waybar](https://github.com/Alexays/Waybar)

**Image viewer**: [imv](https://github.com/eXeC64/imv), [feh](https://github.com/derf/feh)

**Video**: mpv

**Network**: iwd + NetworkManager, `nm-applet --indicator`

**Bluetooth**: blueman with appindicator support
