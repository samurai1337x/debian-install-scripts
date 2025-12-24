#!/usr/bin/env bash
set -e

# ---------------------------------------------------------
# Detect OS
# ---------------------------------------------------------
. /etc/os-release

if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
    echo "Unsupported OS: $ID"
    exit 1
fi

echo "Detected OS: $PRETTY_NAME"

# ---------------------------------------------------------
# Remove old Cloudflared repo & keys
# ---------------------------------------------------------
sudo rm -f /etc/apt/sources.list.d/cloudflared.list
sudo rm -f /etc/apt/sources.list.d/cloudflared.sources
sudo rm -f /etc/apt/keyrings/cloudflare-main.gpg
sudo rm -f /etc/apt/keyrings/cloudflare-secondary.gpg

# ---------------------------------------------------------
# Install prerequisites
# ---------------------------------------------------------
sudo apt update
sudo apt install -y ca-certificates curl gnupg

# ---------------------------------------------------------
# Install Cloudflare GPG key(s)
# ---------------------------------------------------------
sudo install -m 0755 -d /etc/apt/keyrings

# Main key (required everywhere)
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg \
  | sudo gpg --dearmor \
  | sudo tee /etc/apt/keyrings/cloudflare-main.gpg >/dev/null

# Secondary key (Debian only)
if [[ "$ID" == "debian" ]]; then
  curl -fsSL https://pkg.cloudflare.com/cloudflare-secondary.gpg \
    | sudo gpg --dearmor \
    | sudo tee /etc/apt/keyrings/cloudflare-secondary.gpg >/dev/null
fi

sudo chmod a+r /etc/apt/keyrings/cloudflare-*.gpg

# ---------------------------------------------------------
# Determine Cloudflare suite
# ---------------------------------------------------------
CF_CODENAME="$VERSION_CODENAME"

# Debian testing fallback
if [[ "$ID" == "debian" && ( "$VERSION_CODENAME" == "trixie" || "$VERSION_CODENAME" == "sid" ) ]]; then
    CF_CODENAME="bookworm"
fi

# ---------------------------------------------------------
# Add Cloudflared repository
# ---------------------------------------------------------
if [[ "$ID" == "ubuntu" ]]; then
  SIGNED_BY="/etc/apt/keyrings/cloudflare-main.gpg"
else
  SIGNED_BY="/etc/apt/keyrings/cloudflare-main.gpg /etc/apt/keyrings/cloudflare-secondary.gpg"
fi

sudo tee /etc/apt/sources.list.d/cloudflared.sources >/dev/null <<EOF
Types: deb
URIs: https://pkg.cloudflare.com/cloudflared
Suites: $CF_CODENAME
Components: main
Signed-By: $SIGNED_BY
EOF

# ---------------------------------------------------------
# Install Cloudflared
# ---------------------------------------------------------
sudo apt update
sudo apt install -y cloudflared

# ---------------------------------------------------------
# Verify
# ---------------------------------------------------------
cloudflared --version
