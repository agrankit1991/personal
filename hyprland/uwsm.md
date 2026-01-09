install uwsm

```bash
nvim ~/.config/uwsm/hyprland.desktop

[Desktop Entry]
Name=Hyprland (UWSM)
Comment=Hyprland Wayland compositor managed by UWSM
Exec=uwsm start hyprland
Type=Application
DesktopNames=Hyprland
```

```bash
sudo nvim ~/.config/uwsm/env

export TERMINAL=ghostty
export BROWSER=brave
export EDITOR=code
```