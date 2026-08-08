#!/bin/bash
# Disk management component, shared by every Arch desktop script:
# GNOME Disks plus FAT32 (dosfstools) and NTFS (ntfs-3g) support so it can
# actually format/mount those filesystems.
#
# Depends on: shared/lib/{log,packages}.sh, arch/lib/pacman.sh.

install_disk_utility_component() {
    log_section "Disk Utility"

    local repo_root
    repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    read_package_list "$repo_root/arch/packages/disk-utility.txt"
    install_pkg "${PACKAGE_LIST[@]}"

    log_success "GNOME Disks ready (FAT32 + NTFS support installed)"
}
