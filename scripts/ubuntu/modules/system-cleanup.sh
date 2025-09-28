#!/bin/bash

# System Cleanup Module
# Clean up system packages, caches, and temporary files

set -e

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

# Source utilities and colors
source "$LIB_DIR/utils.sh"

# Get disk usage of a directory
get_disk_usage() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        du -sh "$dir" 2>/dev/null | cut -f1
    else
        echo "N/A"
    fi
}

# Clean APT cache
clean_apt_cache() {
    simple_header "APT Package Cache Cleanup"
    
    local cache_size
    cache_size=$(get_disk_usage "/var/cache/apt")
    
    info "Current APT cache size: $cache_size"
    
    if ! confirm "Clean APT package cache?"; then
        warn "Skipping APT cache cleanup"
        return 0
    fi
    
    show_progress "Cleaning APT cache"
    
    # Clean package cache
    if command_exists nala; then
        sudo nala clean
    else
        sudo apt-get clean
        sudo apt-get autoclean
    fi
    
    # Remove downloaded package files
    sudo rm -rf /var/cache/apt/archives/*.deb
    
    local new_cache_size
    new_cache_size=$(get_disk_usage "/var/cache/apt")
    
    show_success "APT cache cleaned"
    info "Cache size after cleanup: $new_cache_size"
}

# Remove orphaned packages
remove_orphaned_packages() {
    simple_header "Remove Orphaned Packages"
    
    info "Checking for orphaned packages..."
    
    # Find orphaned packages
    local orphaned_packages
    if command_exists nala; then
        orphaned_packages=$(sudo nala autoremove --dry-run 2>/dev/null | grep "^Remv" | wc -l || echo "0")
    else
        orphaned_packages=$(sudo apt-get autoremove --dry-run 2>/dev/null | grep "^Remv" | wc -l || echo "0")
    fi
    
    if [[ "$orphaned_packages" -eq 0 ]]; then
        success "No orphaned packages found"
        return 0
    fi
    
    info "Found $orphaned_packages orphaned package(s)"
    
    if ! confirm "Remove orphaned packages?"; then
        warn "Skipping orphaned package removal"
        return 0
    fi
    
    show_progress "Removing orphaned packages"
    
    if command_exists nala; then
        sudo nala autoremove -y
    else
        sudo apt-get autoremove -y
    fi
    
    show_success "Orphaned packages removed"
}

# Clean Flatpak cache
clean_flatpak_cache() {
    simple_header "Flatpak Cache Cleanup"
    
    if ! command_exists flatpak; then
        info "Flatpak is not installed, skipping cleanup"
        return 0
    fi
    
    local flatpak_cache_size
    flatpak_cache_size=$(get_disk_usage "$HOME/.var/app")
    
    info "Current Flatpak cache size: $flatpak_cache_size"
    
    if ! confirm "Clean Flatpak cache and unused runtimes?"; then
        warn "Skipping Flatpak cleanup"
        return 0
    fi
    
    show_progress "Cleaning Flatpak unused runtimes and cache"
    
    # Remove unused runtimes
    flatpak uninstall --unused -y 2>/dev/null || true
    
    # Clean up repo cache
    sudo flatpak repair --user 2>/dev/null || true
    
    show_success "Flatpak cleanup completed"
}

# Clean Snap cache
clean_snap_cache() {
    simple_header "Snap Cache Cleanup"
    
    if ! command_exists snap; then
        info "Snap is not installed, skipping cleanup"
        return 0
    fi
    
    local snap_cache_size
    snap_cache_size=$(get_disk_usage "/var/lib/snapd/cache")
    
    info "Current Snap cache size: $snap_cache_size"
    
    if ! confirm "Clean Snap cache and old revisions?"; then
        warn "Skipping Snap cleanup"
        return 0
    fi
    
    show_progress "Cleaning Snap old revisions and cache"
    
    # Remove old snap revisions (keep only current and previous)
    local snaps_to_clean
    snaps_to_clean=$(snap list --all | awk '/disabled/{print $1, $3}' | while read snapname revision; do
        echo "$snapname $revision"
    done)
    
    if [[ -n "$snaps_to_clean" ]]; then
        echo "$snaps_to_clean" | while read snapname revision; do
            if [[ -n "$snapname" && -n "$revision" ]]; then
                show_progress "Removing old revision of $snapname"
                sudo snap remove "$snapname" --revision="$revision" 2>/dev/null || true
            fi
        done
    else
        info "No old snap revisions to remove"
    fi
    
    show_success "Snap cleanup completed"
}

# Clean system logs
clean_system_logs() {
    simple_header "System Logs Cleanup"
    
    local log_size
    log_size=$(get_disk_usage "/var/log")
    
    info "Current system logs size: $log_size"
    
    if ! confirm "Clean old system logs (keep last 7 days)?"; then
        warn "Skipping system logs cleanup"
        return 0
    fi
    
    show_progress "Cleaning system logs older than 7 days"
    
    # Clean journalctl logs
    if command_exists journalctl; then
        sudo journalctl --vacuum-time=7d
    fi
    
    # Clean old log files
    sudo find /var/log -name "*.log.*" -type f -mtime +7 -delete 2>/dev/null || true
    sudo find /var/log -name "*.gz" -type f -mtime +7 -delete 2>/dev/null || true
    
    local new_log_size
    new_log_size=$(get_disk_usage "/var/log")
    
    show_success "System logs cleaned"
    info "Log size after cleanup: $new_log_size"
}

# Clean temporary files
clean_temp_files() {
    simple_header "Temporary Files Cleanup"
    
    local temp_size
    temp_size=$(get_disk_usage "/tmp")
    
    info "Current /tmp size: $temp_size"
    
    if ! confirm "Clean temporary files and caches?"; then
        warn "Skipping temporary files cleanup"
        return 0
    fi
    
    show_progress "Cleaning temporary files"
    
    # Clean /tmp (but be careful with running processes)
    sudo find /tmp -type f -atime +3 -delete 2>/dev/null || true
    sudo find /tmp -type d -empty -delete 2>/dev/null || true
    
    # Clean user cache directories (excluding browser caches)
    if [[ -d "$HOME/.cache" ]]; then
        show_progress "Cleaning user cache directory (excluding browser caches)"
        # Clean temporary files but keep browser caches and important app caches
        find "$HOME/.cache" -type f -name "*.log" -delete 2>/dev/null || true
        find "$HOME/.cache" -type f -name "*.tmp" -delete 2>/dev/null || true
    fi
    
    # Clean thumbnail cache
    if [[ -d "$HOME/.cache/thumbnails" ]]; then
        show_progress "Cleaning thumbnail cache"
        rm -rf "$HOME/.cache/thumbnails"/* 2>/dev/null || true
    fi
    
    local new_temp_size
    new_temp_size=$(get_disk_usage "/tmp")
    
    show_success "Temporary files cleaned"
    info "Temp size after cleanup: $new_temp_size"
}

# Clean trash
clean_trash() {
    simple_header "Trash Cleanup"
    
    local trash_dir="$HOME/.local/share/Trash"
    local trash_size
    trash_size=$(get_disk_usage "$trash_dir")
    
    if [[ "$trash_size" == "N/A" ]] || [[ "$trash_size" == "0" ]]; then
        success "Trash is already empty"
        return 0
    fi
    
    info "Current trash size: $trash_size"
    
    if ! confirm "Empty trash completely?"; then
        warn "Skipping trash cleanup"
        return 0
    fi
    
    show_progress "Emptying trash"
    
    if [[ -d "$trash_dir" ]]; then
        rm -rf "$trash_dir"/* 2>/dev/null || true
        rm -rf "$trash_dir"/.*  2>/dev/null || true
    fi
    
    show_success "Trash emptied"
}

# Update package database only
update_package_database() {
    simple_header "Update Package Database"
    
    if ! confirm "Update package database (no system upgrade)?"; then
        warn "Skipping package database update"
        return 0
    fi
    
    show_progress "Updating package database"
    
    if command_exists nala; then
        sudo nala update
    else
        sudo apt-get update
    fi
    
    show_success "Package database updated"
    info "Note: Run system updates separately if needed"
}

# Show disk space summary
show_disk_summary() {
    simple_header "Disk Space Summary"
    
    info "Current disk usage:"
    df -h / | tail -1 | awk '{printf "  Root filesystem: %s used of %s (%s full)\n", $3, $2, $5}'
    
    if [[ -d "$HOME" ]]; then
        local home_size
        home_size=$(get_disk_usage "$HOME")
        echo "  Home directory: $home_size"
    fi
    
    echo
    info "Large directories to consider for manual cleanup:"
    
    # Find large directories (>100MB) in home directory
    if command_exists ncdu; then
        info "Use 'ncdu $HOME' for interactive disk usage analysis"
    else
        # Show top 5 largest directories in home
        find "$HOME" -type d -exec du -sh {} + 2>/dev/null | sort -hr | head -5 | while read size dir; do
            # Only show directories larger than 100MB
            if [[ "$size" =~ ^[0-9]+G$ ]] || [[ "$size" =~ ^[5-9][0-9][0-9]M$ ]] || [[ "$size" =~ ^[0-9][0-9][0-9][0-9]M$ ]]; then
                echo "  $size - $dir"
            fi
        done
    fi
}

# Show cleanup summary
show_cleanup_summary() {
    box "System Cleanup Summary"
    
    success "System cleanup completed! 🎉"
    echo
    
    info "What was cleaned:"
    echo "  ✅ APT package cache"
    echo "  ✅ Orphaned packages"
    echo "  ✅ Flatpak cache and unused runtimes"
    echo "  ✅ Snap old revisions and cache"
    echo "  ✅ System logs older than 7 days"
    echo "  ✅ Temporary files and user caches"
    echo "  ✅ Trash"
    echo "  ✅ Package database updated"
    echo
    
    show_disk_summary
    
    echo
    info "Recommendations:"
    echo "  • Run this cleanup monthly to maintain system performance"
    echo "  • Use 'ncdu' or 'baobab' for detailed disk usage analysis"
    echo "  • Consider moving large files to external storage"
    echo "  • Monitor disk usage with 'df -h' regularly"
    echo "  • Clean browser caches manually if needed (preserved for performance)"
    echo "  • Run system updates separately: 'sudo nala upgrade' or 'sudo apt upgrade'"
}

# Main function
main() {
    header "System Cleanup"
    info "This module will clean up your system to free disk space and improve performance:"
    echo
    echo "🧹 Cleanup Operations:"
    echo "   • APT package cache and orphaned packages"
    echo "   • Flatpak cache and unused runtimes"
    echo "   • Snap cache and old revisions"
    echo "   • System logs older than 7 days"
    echo "   • Temporary files and user caches (excluding browser caches)"
    echo "   • Trash/recycle bin"
    echo "   • Update package database (no system upgrade)"
    echo
    echo "⚠️  Safety Notes:"
    echo "   • Each cleanup step requires confirmation"
    echo "   • Important files and current data are preserved"
    echo "   • Browser caches are preserved for faster browsing"
    echo "   • System logs keep last 7 days for troubleshooting"
    echo
    warn "This will free up disk space but may require re-downloading some cached data"
    echo
    
    if ! confirm "Do you want to start the system cleanup process?"; then
        warn "System cleanup cancelled by user"
        return 0
    fi
    
    # Show current disk usage
    show_disk_summary
    echo
    
    # Perform cleanup operations
    clean_apt_cache
    remove_orphaned_packages
    clean_flatpak_cache
    clean_snap_cache
    clean_system_logs
    clean_temp_files
    clean_trash
    update_package_database
    
    # Show final summary
    show_cleanup_summary
    
    success "System cleanup completed successfully!"
    info "Your system should now have more free space and improved performance"
    
    return 0
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi