# Ubuntu Setup Scripts

A modular Ubuntu development environment setup system with shared utilities and consistent styling.

## Directory Structure

```
scripts/ubuntu/
├── setup.sh                    # Main interactive setup script
├── lib/                        # Shared libraries
│   ├── colors.sh               # Color definitions and themes
│   └── utils.sh                # Common utility functions
└── modules/                    # Individual setup modules
    └── system-update.sh        # System update & nala installation
```

## Features

### 🎨 **Shared Libraries**

#### Colors (`lib/colors.sh`)
- **Regular colors**: BLACK, RED, GREEN, YELLOW, BLUE, PURPLE, CYAN, WHITE
- **Bold colors**: BOLD_BLACK, BOLD_RED, etc.
- **Background colors**: BG_BLACK, BG_RED, etc.
- **Special effects**: BOLD, DIM, UNDERLINE, BLINK, REVERSE, HIDDEN
- **Semantic colors**: SUCCESS, ERROR, WARNING, INFO, HIGHLIGHT, HEADER, ACCENT

#### Utilities (`lib/utils.sh`)
- **Logging functions**: `log()`, `warn()`, `error()`, `info()`, `success()`
- **Visual indicators**: `show_progress()`, `show_success()`, `show_error()`, `show_warning()`
- **System checks**: `command_exists()`, `package_installed()`, `is_root()`, `is_ubuntu()`
- **User interaction**: `confirm()`, `pause()`
- **Visual formatting**: `box()`, `simple_header()`, `separator()`
- **File operations**: `backup_file()`, `ensure_dir()`, `download_file()`
- **System utilities**: `get_os_info()`, `check_internet()`

### 🔧 **Module System**
Each module is a standalone script that:
- Sources the shared utilities
- Provides consistent logging and error handling
- Can be run independently or through the main script
- Follows the same visual and interaction patterns

## Usage

### Run the Main Setup Script
```bash
cd /path/to/scripts/ubuntu
./setup.sh
```

### Run Individual Modules
```bash
./modules/system-update.sh
```

### Use Utilities in New Modules
```bash
#!/bin/bash
set -e

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"
source "$LIB_DIR/utils.sh"

# Now you can use all utility functions
box "My Module Title"
info "Starting installation..."
show_progress "Installing packages"

if confirm "Continue with installation?"; then
    # Do installation
    show_success "Installation completed!"
else
    warn "Installation cancelled"
fi
```

## Available Utility Functions

### Logging
- `log "message"` - Timestamped success message
- `warn "message"` - Warning message
- `error "message"` - Error message
- `info "message"` - Info message
- `success "message"` - Success message

### Visual Indicators
- `show_progress "message"` - Shows ⏳ with message
- `show_success "message"` - Shows ✅ with message
- `show_error "message"` - Shows ❌ with message
- `show_warning "message"` - Shows ⚠️ with message

### Visual Formatting
- `box "title"` - Creates a bordered box around text
- `simple_header "text"` - Creates a simple header with underline
- `separator "=" 60` - Creates a separator line
- `highlight "text"` - Highlights text in cyan
- `header "text"` - Formats text as header in blue

### System Checks
- `command_exists "cmd"` - Check if command is available
- `package_installed "pkg"` - Check if apt package is installed
- `is_root` - Check if running as root
- `is_user` - Check if running as regular user
- `is_ubuntu` - Check if system is Ubuntu
- `check_internet` - Check internet connectivity

### User Interaction
- `confirm "message"` - Yes/no confirmation (default: Yes)
- `confirm "message" "N"` - Yes/no confirmation (default: No)
- `pause "message"` - Wait for Enter key

### File Operations
- `backup_file "file"` - Create timestamped backup
- `ensure_dir "directory"` - Create directory if it doesn't exist
- `download_file "url" "output" "description"` - Download with progress
- `add_line_to_file "line" "file"` - Add line if not exists
- `remove_line_from_file "pattern" "file"` - Remove matching lines

## Creating New Modules

1. Create a new script in the `modules/` directory
2. Source the utilities at the top of your script
3. Use the utility functions for consistent behavior
4. Add your module to the main menu in `setup.sh`

Example module template:
```bash
#!/bin/bash
set -e

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"
source "$LIB_DIR/utils.sh"

# Main function
main() {
    box "My Module Name"
    
    info "This module will install/configure something"
    
    if ! confirm "Do you want to continue?"; then
        warn "Installation cancelled"
        exit 0
    fi
    
    show_progress "Installing something"
    # Your installation logic here
    show_success "Installation completed!"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## Color Usage Examples

```bash
# Using semantic colors
echo -e "${SUCCESS}This is a success message${NC}"
echo -e "${ERROR}This is an error message${NC}"
echo -e "${WARNING}This is a warning message${NC}"
echo -e "${INFO}This is an info message${NC}"

# Using specific colors
echo -e "${BOLD_BLUE}Bold blue text${NC}"
echo -e "${UNDERLINE}${GREEN}Underlined green text${NC}"
```