#!/bin/bash

# System Cleanup Module
# Clean up package cache and unused packages

set -e

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

# Source utilities and colors
source "$LIB_DIR/utils.sh"

# Show disk usage
show_disk_usage() {
    simple_header "Disk Usage"
    
    if command_exists duf; then
        duf
    else
        df -h
    fi
    
    echo
}

# Clean DNF cache
clean_dnf_cache() {
    simple_header "DNF Cache Cleanup"
    
    if confirm "Clean DNF package cache?"; then
        show_progress "Cleaning DNF cache"
        sudo dnf clean all
        show_success "DNF cache cleaned"
        
        # Show cache size
        local cache_size=$(du -sh /var/cache/dnf 2>/dev/null | cut -f1)
        info "Current cache size: $cache_size"
    else
        warn "Skipping DNF cache cleanup"
    fi
    
    echo
}

# Remove unused packages
remove_unused_packages() {
    simple_header "Remove Unused Packages"
    
    if confirm "Remove unused packages (autoremove)?"; then
        show_progress "Removing unused packages"
        sudo dnf autoremove -y
        show_success "Unused packages removed"
    else
        warn "Skipping unused package removal"
    fi
    
    echo
}

# Clean old kernels
clean_old_kernels() {
    simple_header "Old Kernel Cleanup"
    
    info "Currently installed kernels:"
    rpm -qa kernel | sort -V
    echo
    
    local kernel_count=$(rpm -qa kernel | wc -l)
    info "Total kernels installed: $kernel_count"
    echo
    
    if [[ $kernel_count -gt 3 ]]; then
        warn "You have $kernel_count kernels installed"
        
        if confirm "Remove old kernels (keep latest 3)?"; then
            show_progress "Removing old kernels"
            sudo dnf remove $(dnf repoquery --installonly --latest-limit=-3 -q)
            show_success "Old kernels removed"
        else
            warn "Skipping kernel cleanup"
        fi
    else
        info "No old kernels to remove"
    fi
    
    echo
}

# Clean Flatpak
clean_flatpak() {
    simple_header "Flatpak Cleanup"
    
    if ! command_exists flatpak; then
        warn "Flatpak is not installed"
        return 0
    fi
    
    if confirm "Clean unused Flatpak runtimes?"; then
        show_progress "Cleaning Flatpak"
        flatpak uninstall --unused -y || true
        show_success "Flatpak cleaned"
    else
        warn "Skipping Flatpak cleanup"
    fi
    
    echo
}

# Clean user cache
clean_user_cache() {
    simple_header "User Cache Cleanup"
    
    local cache_size=$(du -sh ~/.cache 2>/dev/null | cut -f1)
    info "Current user cache size: $cache_size"
    echo
    
    if confirm "Clean user cache (~/.cache)?"; then
        warn "This will remove temporary files and may log you out of some applications"
        
        if confirm "Are you sure you want to continue?"; then
            show_progress "Cleaning user cache"
            
            # Clean specific cache directories
            rm -rf ~/.cache/thumbnails/* 2>/dev/null || true
            rm -rf ~/.cache/mozilla/* 2>/dev/null || true
            rm -rf ~/.cache/chromium/* 2>/dev/null || true
            
            show_success "User cache cleaned"
            
            local new_cache_size=$(du -sh ~/.cache 2>/dev/null | cut -f1)
            info "New cache size: $new_cache_size"
        fi
    else
        warn "Skipping user cache cleanup"
    fi
    
    echo
}

# Clean journal logs
clean_journal_logs() {
    simple_header "Journal Log Cleanup"
    
    local log_size=$(sudo journalctl --disk-usage | grep -oP '\d+\.?\d*\s*[GM]' | head -1)
    info "Current journal size: $log_size"
    echo
    
    if confirm "Clean old journal logs (keep last 7 days)?"; then
        show_progress "Cleaning journal logs"
        sudo journalctl --vacuum-time=7d
        show_success "Journal logs cleaned"
        
        local new_log_size=$(sudo journalctl --disk-usage | grep -oP '\d+\.?\d*\s*[GM]' | head -1)
        info "New journal size: $new_log_size"
    else
        warn "Skipping journal log cleanup"
    fi
    
    echo
}

# Clean temporary files
clean_temp_files() {
    simple_header "Temporary Files Cleanup"
    
    if confirm "Clean system temporary files (/tmp)?"; then
        show_progress "Cleaning temporary files"
        sudo rm -rf /tmp/* 2>/dev/null || true
        show_success "Temporary files cleaned"
    else
        warn "Skipping temporary files cleanup"
    fi
    
    echo
}

# Show cleanup summary
show_cleanup_summary() {
    simple_header "Cleanup Summary"
    
    info "Disk usage after cleanup:"
    echo
    
    if command_exists duf; then
        duf
    else
        df -h /
    fi
    
    echo
    
    info "Package statistics:"
    local installed_packages=$(dnf list installed | wc -l)
    echo "  • DNF packages installed: $installed_packages"
    
    if command_exists flatpak; then
        local flatpak_apps=$(flatpak list --app | wc -l)
        local flatpak_runtimes=$(flatpak list --runtime | wc -l)
        echo "  • Flatpak apps: $flatpak_apps"
        echo "  • Flatpak runtimes: $flatpak_runtimes"
    fi
    
    echo
}

main() {
    box "System Cleanup"
    
    info "This module cleans up package cache and unused files"
    echo
    
    warn "Some cleanup operations may require significant disk I/O"
    echo
    
    if ! confirm "Do you want to proceed with system cleanup?"; then
        warn "System cleanup cancelled"
        exit 0
    fi
    
    echo
    
    # Show initial disk usage
    show_disk_usage
    
    # Cleanup operations
    clean_dnf_cache
    remove_unused_packages
    clean_old_kernels
    clean_flatpak
    clean_journal_logs
    clean_temp_files
    clean_user_cache
    
    # Show summary
    show_cleanup_summary
    
    show_success "System cleanup completed"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
