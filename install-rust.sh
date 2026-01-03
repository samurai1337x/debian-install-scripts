#!/bin/bash

################################################################################
# Install Rust Installation Script
# 
# Description:
#   Installs Rust programming language and Cargo package manager on 
#   Debian/Ubuntu systems using the official rustup installer.
#
# Supported Distributions:
#   - Debian: Bullseye (11), Bookworm (12), Trixie (13)
#   - Ubuntu: 20.04 LTS, 22.04 LTS, 24.04 LTS
#
# Usage:
#   sudo bash install-rust.sh
#
# Author: debian-install-scripts
# License: MIT
################################################################################

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    log_error "This script must be run as root or with sudo"
    exit 1
fi

# Detect distribution
detect_distribution() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO="$ID"
        VERSION_CODENAME="$VERSION_CODENAME"
    else
        log_error "Cannot detect distribution"
        exit 1
    fi
}

# Update package lists
update_package_lists() {
    log_info "Updating package lists..."
    apt-get update -y
    log_success "Package lists updated"
}

# Install prerequisites
install_prerequisites() {
    log_info "Installing build tools and prerequisites..."
    apt-get install -y build-essential curl wget git libssl-dev pkg-config
    log_success "Prerequisites installed"
}

# Download and run rustup installer
install_rust() {
    local rustup_init=$(mktemp)
    
    log_info "Downloading rustup installer..."
    curl -fsSL https://sh.rustup.rs -o "$rustup_init"
    chmod +x "$rustup_init"
    
    log_info "Running rustup installer..."
    RUSTUP_INIT_SKIP_PATH_CHECK=yes "$rustup_init" -y --default-toolchain stable
    
    rm -f "$rustup_init"
    log_success "Rust installation complete"
}

# Setup environment
setup_environment() {
    log_info "Setting up Rust environment..."
    
    if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
        log_success "Environment configured"
    fi
}

# Verify installation
verify_installation() {
    log_info "Verifying Rust installation..."
    
    export PATH="$HOME/.cargo/bin:$PATH"
    
    local rustc_version=$(rustc --version)
    local cargo_version=$(cargo --version)
    
    log_success "Installation verified"
    log_info "$rustc_version"
    log_info "$cargo_version"
}

# Print post-installation instructions
print_instructions() {
    cat << 'EOF'

================================================================================
Rust Installation Complete!
================================================================================

Getting Started:
  cargo new my-project              # Create new Rust project
  cd my-project && cargo run        # Run project
  cargo build --release             # Build optimized binary
  cargo test                        # Run tests

Toolchain Management:
  rustup update                     # Update Rust to latest version
  rustup show                       # Show current toolchain information

Project Management:
  cargo add <crate>                 # Add dependency
  cargo check                       # Quick syntax check
  cargo clean                       # Clean build artifacts

Code Quality:
  cargo fmt                         # Format code
  cargo clippy                      # Lint code

Make sure to add Rust to your PATH:
  export PATH="$HOME/.cargo/bin:$PATH"

For more information, visit: https://www.rust-lang.org/
Rust Book: https://doc.rust-lang.org/book/

================================================================================

EOF
}

# Main execution
main() {
    log_info "Starting Rust installation..."
    
    detect_distribution
    log_info "Detected distribution: $DISTRO ($VERSION_CODENAME)"
    
    update_package_lists
    install_prerequisites
    install_rust
    setup_environment
    verify_installation
    print_instructions
    
    log_success "Rust installation completed successfully!"
}

main
