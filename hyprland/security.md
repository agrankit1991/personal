# Firewall
sudo pacman -S ufw
sudo systemctl enable --now ufw

## Set Rules
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

## Check Status:
sudo ufw status verbose


# AppArmor because SELinux is very hard to setup on Arch
sudo pacman -S apparmor apparmor-utils
# Audit Framework related packages
sudo pacman -S python-audit python-notify2 python-psutil
# Add missing dependency
sudo pacman -S tk

## enable extra profiles
paru -S krathalans-apparmor-profiles-git

## Add below line in kernel parameter
### lsm=landlock,lockdown,yama,integrity,apparmor,bpf
## if using sddm add it like below, lsm parameter in GRUB_CMDLINE_LINUX_DEFAULT applies to the entire system (the Linux Kernel), not specifically to SDDM
```bash
sudo nvim /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet lsm=landlock,lockdown,yama,integrity,apparmor,bpf"
```
## add audit=1 for eanbling auditing framework, will be used alongwith AppArmor
```bash
sudo nvim /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet lsm=landlock,lockdown,yama,integrity,apparmor,bpf audit=1"
```

## regenerate grub config
sudo grub-mkconfig -o /boot/grub/grub.cfg

## enable the service
sudo systemctl enable --now apparmor.service
sudo systemctl enable --now auditd.service

## Get desktop notification on DENIED actions
```
sudo groupadd -r audit
sudo gpasswd -a $USER audit
```
### Add audit group to auditd.conf: /etc/audit/auditd.conf
### change existing log_group do not add new one
log_group = audit

## Create a desktop launcher with the below content: ~/.config/autostart/apparmor-notify.desktop
```
[Desktop Entry]
Type=Application
Name=AppArmor Notify
Comment=Receive on screen notifications of AppArmor denials
TryExec=aa-notify
Exec=aa-notify -p -s 1 -w 60 -f /var/log/audit/audit.log
StartupNotify=false
NoDisplay=true
```

### Reboot and check if the aa-notify process is running:
pgrep -ax aa-notify

## Speed-up AppArmor start by caching profiles
systemd-analyze blame | grep apparmor # used to check current time taken

### To enable caching AppArmor profiles, uncomment: /etc/apparmor/parser.conf
### Since 2.13.1 default cache location is /var/cache/apparmor/, previously it was /etc/apparmor.d/cache.d/
```
## Turn creating/updating of the cache on by default
write-cache
```
### Reboot and check AppArmor startup time again to see improvement:
systemd-analyze blame | grep apparmor


## Prevent AppArmor to restrict waybar
sudo bash -c 'echo "/usr/share/xkeyboard-config-2/** r," > /etc/apparmor.d/local/waybar'
sudo bash -c 'echo "/usr/bin/swaync-client ix," >> /etc/apparmor.d/local/waybar'

### Reload AppArmor
sudo apparmor_parser -r /etc/apparmor.d/waybar