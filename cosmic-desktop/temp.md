# External Monitor Brightness

git clone https://github.com/cosmic-utils/cosmic-ext-applet-external-monitor-brightness

just build-release && sudo just install

install ddcutil
sudo usermod -aG i2c $USER

## Verify the i2c-dev module is loaded
lsmod | grep i2c_dev

## If that returns nothing, load it manually to test:
sudo modprobe i2c-dev

## To make this permanent: Create a file to load it at boot:
echo "i2c-dev" | sudo tee /etc/modules-load.d/i2c-dev.conf



# Numlock
/var/lib/cosmic-greeter/.config/cosmic/com.system76.CosmicComp/v1/keyboard_config
```
(
numlock_state: BootOn,
)
```

# GTK apps UI issue
install xdg-desktop-portal-gtk


# CS GO
SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0 %command%

