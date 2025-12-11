#!/usr/bin/env bash

# ---------------------------------------------------------
# Remove old Cloudflared repo & key (avoid conflicts)
# ---------------------------------------------------------
sudo rm -f /etc/apt/sources.list.d/cloudflared.list
sudo rm -f /etc/apt/sources.list.d/cloudflared.sources
sudo rm -f /usr/share/keyrings/cloudflare-main.gpg
sudo rm -f /etc/apt/keyrings/cloudflare-main.asc

# ---------------------------------------------------------
# Install prerequisites
# ---------------------------------------------------------
sudo apt update
sudo apt install -y ca-certificates curl gnupg

# ---------------------------------------------------------
# Add Cloudflare GPG key
# ---------------------------------------------------------
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg \
    | sudo tee /etc/apt/keyrings/cloudflare-main.asc >/dev/null
sudo chmod a+r /etc/apt/keyrings/cloudflare-main.asc

# ---------------------------------------------------------
# Load OS info
# ---------------------------------------------------------
. /etc/os-release

# Force Bookworm for Trixie (Cloudflare does NOT provide trixie repo)
if [ "$VERSION_CODENAME" = "trixie" ]; then
    CF_CODENAME="bookworm"
else
    CF_CODENAME="$VERSION_CODENAME"
fi

# ---------------------------------------------------------
# Add Cloudflare repo using correct URL
# ---------------------------------------------------------
sudo tee /etc/apt/sources.list.d/cloudflared.sources >/dev/null <<EOF
Types: deb
URIs: https://pkg.cloudflare.com/cloudflared
Suites: $CF_CODENAME
Components: main
Signed-By: /etc/apt/keyrings/cloudflare-main.asc
EOF

# ---------------------------------------------------------
# Install Cloudflared
# ---------------------------------------------------------
sudo apt update
sudo apt install -y cloudflared
