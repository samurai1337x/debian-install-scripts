#!/bin/bash

################################################################################
# Install Node.js Installation Script
# 
# Description:
#   Installs Node.js and npm on Debian/Ubuntu systems.
#   Includes automatic repository configuration and GPG key setup.
#
# Supported Distributions:
#   - Debian: Bullseye (11), Bookworm (12), Trixie (13)
#   - Ubuntu: 20.04 LTS, 22.04 LTS, 24.04 LTS
#
# Usage:
#   sudo bash install-nodejs.sh
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
    log_info "Installing prerequisites..."
    apt-get install -y ca-certificates curl gnupg
    log_success "Prerequisites installed"
}

# Add NodeSource GPG key
add_nodejs_gpg_key() {
    log_info "Adding Node.js GPG key..."
    
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | \
        gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    
    log_success "Node.js GPG key added"
}

# Add NodeSource repository
add_nodejs_repository() {
    log_info "Adding Node.js repository..."
    
    local arch=$(dpkg --print-architecture)
    echo "deb [arch=$arch signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x $VERSION_CODENAME main" | \
        tee /etc/apt/sources.list.d/nodesource.list > /dev/null
    
    log_success "Node.js repository added"
}

# Install Node.js
install_nodejs() {
    log_info "Installing Node.js..."
    apt-get install -y nodejs
    log_success "Node.js installed"
}

# Verify installation
verify_installation() {
    log_info "Verifying installation..."
    
    local node_version=$(node --version)
    local npm_version=$(npm --version)
    
    log_success "Installation verified"
    log_info "Node.js version: $node_version"
    log_info "npm version: $npm_version"
}

# Print post-installation instructions
print_instructions() {
    cat << 'EOF'

================================================================================
Node.js Installation Complete!
================================================================================

Useful npm commands:
  npm install -g <package>          # Install a package globally
  npm init                           # Create a new project
  npm install                        # Install project dependencies
  npm start                          # Run project

Create new Node.js project:
  mkdir my-project && cd my-project
  npm init -y
  npm install express

For more information, visit: https://nodejs.org/

================================================================================

EOF
}

# Main execution
main() {
    log_info "Starting Node.js installation..."
    
    detect_distribution
    log_info "Detected distribution: $DISTRO ($VERSION_CODENAME)"
    
    update_package_lists
    install_prerequisites
    add_nodejs_gpg_key
    add_nodejs_repository
    update_package_lists
    install_nodejs
    verify_installation
    print_instructions
    
    log_success "Node.js installation completed successfully!"
}

main
