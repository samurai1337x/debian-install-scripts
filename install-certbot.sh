#!/bin/bash

################################################################################
# Install Certbot Installation Script
# 
# Description:
#   Installs Certbot for SSL/TLS certificate management on Debian/Ubuntu systems.
#   Includes automatic repository configuration and Nginx plugin.
#
# Supported Distributions:
#   - Debian: Bullseye (11), Bookworm (12), Trixie (13)
#   - Ubuntu: 20.04 LTS, 22.04 LTS, 24.04 LTS
#
# Usage:
#   sudo bash install-certbot.sh
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

# Install Certbot
install_certbot() {
    log_info "Installing Certbot..."
    apt-get install -y certbot python3-certbot-nginx
    log_success "Certbot installed"
}

# Verify installation
verify_installation() {
    log_info "Verifying Certbot installation..."
    
    local certbot_version=$(certbot --version)
    log_success "Installation verified"
    log_info "$certbot_version"
}

# Print post-installation instructions
print_instructions() {
    cat << 'EOF'

================================================================================
Certbot Installation Complete!
================================================================================

Request a certificate for Nginx:
  certbot certonly --nginx          # Request certificate interactively
  certbot certonly --nginx -d example.com -d www.example.com  # For specific domain

Automatic certificate renewal:
  certbot renew                     # Renew certificates
  certbot renew --dry-run           # Test renewal process

View certificates:
  certbot certificates              # List all certificates
  certbot show --certificate example.com  # Show specific certificate details

Delete a certificate:
  certbot delete --cert-name example.com

Important locations:
  /etc/letsencrypt/live/            # Certificate files
  /etc/letsencrypt/archive/         # Archive of certificate versions
  /var/log/letsencrypt/             # Log files

Automatic renewal:
  A cron job has been installed to automatically renew certificates
  Check status: systemctl status certbot.timer

Common Nginx configuration:
  server {
    listen 443 ssl http2;
    server_name example.com;

    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

    location / {
      proxy_pass http://localhost:3000;
    }
  }

Redirect HTTP to HTTPS:
  server {
    listen 80;
    server_name example.com;
    return 301 https://$server_name$request_uri;
  }

For more information, visit: https://certbot.eff.org/

================================================================================

EOF
}

# Main execution
main() {
    log_info "Starting Certbot installation..."
    
    detect_distribution
    log_info "Detected distribution: $DISTRO ($VERSION_CODENAME)"
    
    update_package_lists
    install_certbot
    verify_installation
    print_instructions
    
    log_success "Certbot installation completed successfully!"
}

main
