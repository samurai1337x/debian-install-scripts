#!/usr/bin/env bash

# ---------------------------------------------------------
# Remove conflicting Docker-related packages
# ---------------------------------------------------------
CONFLICT_PKGS=$(dpkg --get-selections \
    docker.io docker-compose docker-doc podman-docker containerd runc 2>/dev/null | cut -f1)

if [ -n "$CONFLICT_PKGS" ]; then
    echo "Removing conflicting packages: $CONFLICT_PKGS"
    sudo apt remove -y $CONFLICT_PKGS
fi

# ---------------------------------------------------------
# Clean any old Docker sources to avoid Signed-By conflicts
# ---------------------------------------------------------
sudo rm -f /etc/apt/sources.list.d/docker.list
sudo rm -f /etc/apt/sources.list.d/docker.sources
sudo rm -f /etc/apt/keyrings/docker.gpg
sudo rm -f /etc/apt/keyrings/docker.asc

# ---------------------------------------------------------
# Install prerequisites
# ---------------------------------------------------------
sudo apt update
sudo apt install -y ca-certificates curl

# ---------------------------------------------------------
# Add Docker's official GPG key
# ---------------------------------------------------------
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg \
    -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# ---------------------------------------------------------
# Load OS release info
# ---------------------------------------------------------
. /etc/os-release

# ---------------------------------------------------------
# Add Docker repository using modern .sources format
# ---------------------------------------------------------
sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $VERSION_CODENAME
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# ---------------------------------------------------------
# Install Docker Engine + CLI + Compose + Buildx
# ---------------------------------------------------------
sudo apt update
sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
