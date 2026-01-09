# Minimal Arch Linux + Hyprland Installation Guide

## Part 1: Basic Arch Installation

### Prerequisites
- Arch Linux ISO on USB drive
- UEFI system (modern systems)
- Internet connection

### Step 1: Boot into Live Environment

Boot from USB and verify UEFI mode:
```bash
ls /sys/firmware/efi/efivars
# If you see files, you're in UEFI mode
```

Connect to internet:
```bash
# For WiFi
iwctl
[iwd]# device list
[iwd]# station wlan0 scan
[iwd]# station wlan0 get-networks
[iwd]# station wlan0 connect "YourSSID"
[iwd]# exit

# Test connection
ping -c 3 archlinux.org
```

Update system clock:
```bash
timedatectl set-ntp true
```

### Step 2: Disk Partitioning

List disks:
```bash
lsblk
# Identify your disk (usually /dev/sda or /dev/nvme0n1)
```

**Partition scheme for BTRFS with snapshots:**

```bash
# Replace /dev/sda with your disk
cfdisk /dev/sda
```

Create these partitions:
- `/dev/sda1` - 512M - EFI System (Type: EFI System)
- `/dev/sda2` - Rest - Linux filesystem (Type: Linux filesystem)

**Format partitions:**
```bash
# EFI partition
mkfs.fat -F32 /dev/sda1

# Root partition with BTRFS
mkfs.btrfs -L arch /dev/sda2
```

### Step 3: Create BTRFS Subvolumes (for snapshots)

```bash
# Mount the BTRFS partition
mount /dev/sda2 /mnt

# Create subvolumes
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache

# Unmount
umount /mnt
```

### Step 4: Mount Subvolumes

```bash
# Mount options for better performance and SSD optimization
MOUNT_OPTS="defaults,noatime,compress=zstd,commit=120"

# Mount root subvolume
mount -o $MOUNT_OPTS,subvol=@ /dev/sda2 /mnt

# Create mount points
mkdir -p /mnt/{boot/efi,home,.snapshots,var/log,var/cache}

# Mount other subvolumes
mount -o $MOUNT_OPTS,subvol=@home /dev/sda2 /mnt/home
mount -o $MOUNT_OPTS,subvol=@snapshots /dev/sda2 /mnt/.snapshots
mount -o $MOUNT_OPTS,subvol=@log /dev/sda2 /mnt/var/log
mount -o $MOUNT_OPTS,subvol=@cache /dev/sda2 /mnt/var/cache

# Mount EFI partition
mount /dev/sda1 /mnt/boot/efi
```

Verify mounts:
```bash
lsblk
```

### Step 5: Install Base System

```bash
# Install base packages
pacstrap -K /mnt base base-devel linux linux-firmware btrfs-progs

# Essential utilities
pacstrap -K /mnt nvim sudo networkmanager git wget
```

### Step 6: Generate fstab

```bash
genfstab -U /mnt >> /mnt/etc/fstab

# Verify fstab
cat /mnt/etc/fstab
```

### Step 7: Chroot into New System

```bash
arch-chroot /mnt
```

### Step 8: Basic System Configuration

**Set timezone:**
```bash
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
```

**Localization:**
```bash
# Edit locale.gen
nvim /etc/locale.gen
# Uncomment: en_US.UTF-8 UTF-8

# Generate locales
locale-gen

# Set locale
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

**Set hostname:**
```bash
echo "archlinux" > /etc/hostname

# Edit hosts file
nvim /etc/hosts
```

Add these lines:
```
127.0.0.1    localhost
::1          localhost
127.0.1.1    archlinux.localdomain archlinux
```

**Set root password:**
```bash
passwd
```

### Step 9: Create User Account

```bash
# Create user (replace 'username' with your preferred username)
useradd -m -G wheel,audio,video,storage,power -s /bin/bash username

# Set user password
passwd username

# Enable sudo for wheel group
EDITOR=nvim visudo
# Uncomment: %wheel ALL=(ALL:ALL) ALL
```

### Step 10: Install Bootloader (GRUB)

```bash
# Install GRUB packages
pacman -S grub efibootmgr os-prober

# Install GRUB to EFI
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

# Generate GRUB config
grub-mkconfig -o /boot/grub/grub.cfg
```

### Step 11: Setup zram

```bash
# Install zram generator
pacman -S zram-generator

# Create config
nvim /etc/systemd/zram-generator.conf
```

Add:
```ini
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
```

### Step 12: Enable NetworkManager

```bash
systemctl enable NetworkManager
```

### Step 13: Exit and Reboot

```bash
# Exit chroot
exit

# Unmount all
umount -R /mnt

# Reboot
reboot
```

### Step 14: Install Snapshot Tools (Snapper + grub-btrfs)

```bash
# Install snapshot tools
sudo pacman -S snapper snap-pac grub-btrfs inotify-tools

# Create snapper config for root
umount /.snapshots
sudo rm -r /.snapshots
sudo snapper create-config /

# Delete auto-created subvolume and mount our @snapshots
btrfs subvolume delete /.snapshots
mkdir /.snapshots
mount -a

# Set snapshot permissions
sudo chmod 750 /.snapshots
```

**Configure Snapper:**
```bash
sudo nvim /etc/snapper/configs/root
```

Modify these values:
```
TIMELINE_MIN_AGE="1800"
TIMELINE_LIMIT_HOURLY="5"
TIMELINE_LIMIT_DAILY="7"
TIMELINE_LIMIT_WEEKLY="0"
TIMELINE_LIMIT_MONTHLY="0"
TIMELINE_LIMIT_YEARLY="0"
```

**Enable services:**
```bash
sudo systemctl enable snapper-timeline.timer
sudo systemctl enable snapper-cleanup.timer
sudo systemctl enable grub-btrfsd.service
```

---

## Part 2: Post-Installation - Installing Hyprland (Coming Next)

After rebooting, remove the USB drive and boot into your new system. Log in as your user.

**Next steps will cover:**
- Installing Hyprland compositor
- Installing SDDM display manager
- Essential Wayland utilities
- Hyprland configuration
- Panel, notifications, and other DE components

---

## Quick Reference: Snapshot Management

**Create manual snapshot:**
```bash
sudo snapper create --description "Before update"
```

**List snapshots:**
```bash
sudo snapper list
```

**Boot into snapshot:**
- During boot, select "Arch Linux snapshots" in GRUB menu
- Choose a snapshot to boot from

**Rollback to snapshot:**
```bash
# From within the system
sudo snapper undochange 1..2

# Or set default subvolume to a snapshot
sudo btrfs subvolume set-default [snapshot-id] /
```

---

## Notes

- **BTRFS subvolumes** allow you to take snapshots of your root filesystem
- **Snapper** automatically creates snapshots before package updates
- **grub-btrfs** adds snapshot entries to GRUB menu for easy recovery
- **zram** provides compressed swap in RAM (faster than disk swap)
- This setup gives you a solid foundation for Hyprland

**Ready for Part 2?** After successful reboot and login, we'll install Hyprland and all the desktop components.