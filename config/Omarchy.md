# Waybar
"clock": {
    "format": "{:%H:%M %A}",
    "format-alt": "{:L%d %B %Y}",
    "tooltip": false,
    "on-click-right": "omarchy-cmd-tzupdate"
  },

---

# Monitors
monitor=HDMI-A-1,2560x1080,0x0,1
monitor=DP-3,1920x1080,2560x0,1
monitor=DP-1,1920x1080,4480x0,1

---

# Hyprland
## Config for Intellij Idea
windowrulev2 = opacity 1.0, class:^(java-lang-ProcessManager)$,title:^(Idea)$
env = _JAVA_AWT_WM_NONREPARENTING=1
env = GDK_SCALE,1

## === Workspace Rules ===
### Assign workspaces to specific monitors
workspace = 1, monitor:HDMI-A-1
workspace = 2, monitor:DP-3
workspace = 3, monitor:DP-1
workspace = 4, monitor:HDMI-A-1
workspace = 5, monitor:DP-3
workspace = 6, monitor:DP-1

---

# Keybindings
bindd = SUPER, return, Terminal, exec, $terminal --working-directory="$(omarchy-cmd-terminal-cwd)"
bindd = SUPER, F, File manager, exec, uwsm app -- nautilus --new-window
bindd = SUPER, B, Browser, exec, $browser
bindd = SUPER SHIFT, B, Browser (private), exec, $browser --private
bindd = SUPER, M, Music, exec, omarchy-launch-or-focus spotify
bindd = SUPER, N, Editor, exec, omarchy-launch-editor
bindd = SUPER, T, Activity, exec, $terminal -e btop
bindd = SUPER SHIFT, D, Docker, exec, $terminal -e lazydocker
bindd = SUPER, O, Obsidian, exec, omarchy-launch-or-focus obsidian "uwsm app -- obsidian -disable-gpu --enable-wayland-ime"
bindd = SUPER, slash, Passwords, exec, uwsm app -- 1password
bindd = SUPER, C, Code, exec, omarchy-launch-or-focus code
bindd = SUPER, I, Intellij Idea CE, exec, omarchy-launch-or-focus idea-ce 
bindd = SUPER SHIFT, C, Calendar, exec, omarchy-launch-or-focus gnome-calendar
bindd = SUPER, E, Email, exec, omarchy-launch-or-focus thunderbird

## If your web app url contains #, type it as ## to prevent hyperland treat it as comments
bindd = SUPER, G, Gemini, exec, omarchy-launch-webapp "https://gemini.google.com/app"
bindd = SUPER, D, Discord, exec, omarchy-launch-webapp "https://discord.com/channels/@me"