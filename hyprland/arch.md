sudo pacman -S --needed git nvim less swaync noto-fonts waybar hyprpaper hyprlauncher cliphist hypridle hyprlock hyprpolkitagent hyprland-qt-support hyprcursor xdg-user-dirs sddm unzip rofi hyprshot fastfetch swayosd
yay -S hyprpolkitagent mkinitcpio-numlock

# font
sudo pacman -S --needed inter-font ttf-jetbrains-mono-nerd noto-fonts-extra texlive-fontsextra
# Install fonts
~/.local/share/fonts/
fc-cache -fv

# Files which has some edits
# https://wiki.hypr.land/Hypr-Ecosystem/hyprqt6engine/
/etc/environment
~/.config/hypr

# enable nvidia modules and numlock on startup, numlock should be before decrypt
/etc/mkinitcpio.conf

# This will create directory structures in Home directory
xdg-user-dirs-update

# Enable SDDM
sudo systemctl enable sddm.service
sudo systemctl start sddm.service

# To keep the numlock on the changes needed are in three places
# https://wiki.archlinux.org/title/Activating_numlock_on_bootup
1. /etc/mkinitcpio.conf
2. /etc/sddm.conf
3. ~/.config/hypr/hyprland.conf



# Auto hide waybar (not using it)
https://github.com/Zephirus2/waybar_auto_hide


# SDDM theme - Black hole - Omarchy wallpaper
https://github.com/Keyitdev/sddm-astronaut-theme


# Gnome Keyring
sudo pacman -S gnome-keyring libsecret seahorse
# The gnome-keyring-daemon starts automatically via systemd user services on login. If not, enable it manually:
systemctl --user enable --now gnome-keyring-daemon.service gnome-keyring-daemon.socket
# Edit /etc/pam.d/login (for console login)
```
# In the 'auth' section (before 'account'):
auth       optional     pam_gnome_keyring.so

# In the 'session' section (after 'account'):
session    optional     pam_gnome_keyring.so auto_start
```
# Full example for /etc/pam.d/login:
```
auth       requisite    pam_nologin.so
auth       include      system-local-login
auth       optional     pam_gnome_keyring.so
account    include      system-local-login
session    include      system-local-login
session    optional     pam_gnome_keyring.so auto_start
password   include      system-local-login
```
# To sync keyring password changes with your user password (e.g., after passwd):
# Add to /etc/pam.d/passwd:
password optional pam_gnome_keyring.so

# Enable for SSH
systemctl --user enable --now gcr-ssh-agent.socket
export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh
ssh-add ~/.ssh/id_ed25519

# Add below line in below files
--password-store=gnome
~/.config/chromium-flags.conf
~/.config/brave-flags.conf


## steam cs2 flag
SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0 %command%