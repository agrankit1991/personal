#!/bin/bash

# CLI Tools Installation Functions
# Part of Terminal Improvements Module

# Install package group with individual error handling
install_cli_tools() {
    simple_header "Modern CLI Tools"
    
    info "Installing modern CLI tools..."
    
    for tool in "${CLI_TOOLS[@]}"; do
        local tool_name="${tool%%:*}"
        local tool_desc="${tool##*:}"
        
        if dnf_package_installed "$tool_name" || command_exists "$tool_name"; then
            echo "  ✅ $tool_desc (already installed)"
        else
            show_progress "Installing $tool_desc"
            if sudo dnf install -y "$tool_name" 2>/dev/null; then
                echo "  ✅ $tool_desc installed successfully"
            else
                echo "  ⚠️  $tool_desc failed to install (skipping)"
            fi
        fi
    done
    
    echo
}

# Show usage tips
show_terminal_tips() {
    box "Terminal Improvements - Usage Tips"
    
    info "🚀 Modern CLI Tools Usage:"
    command_exists rg && echo "  • rg 'pattern' - Search text (better than grep)"
    command_exists fd && echo "  • fd filename - Find files (better than find)"
    command_exists bat && echo "  • bat file.txt - View files with syntax highlighting"
    command_exists eza && echo "  • eza -la - List files with colors and icons"
    command_exists duf && echo "  • duf - Show disk usage with colors"
    command_exists ncdu && echo "  • ncdu - Interactive disk usage analyzer"
    command_exists fzf && echo "  • fzf - Interactive fuzzy finder"
    
    echo
    info "🎯 Productivity Tools:"
    command_exists zoxide && echo "  • z directory - Jump to frequently used directories"
    
    echo
    info "📚 Learning Tools:"
    command_exists tldr && echo "  • tldr command - Get quick examples for commands"
    command_exists fastfetch && echo "  • fastfetch - Show system information (installed via Essential Packages)"
    
    echo
    success "Terminal improvements installation completed! 🎉"
    
    echo
    info "Pro tips:"
    echo "  • Use 'rg pattern' instead of 'grep -r pattern'"
    echo "  • Use 'fd filename' instead of 'find . -name filename'"
    echo "  • Use 'bat file.txt' instead of 'cat file.txt'"
    echo "  • Use 'eza -la' instead of 'ls -la'"
    echo "  • Use 'z directory' instead of 'cd /long/path/to/directory'"
    echo "  • Press Ctrl+R and start typing to use fzf for history search"
}
