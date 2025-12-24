#!/usr/bin/env bash
set -e

# ---------------------------------------------------------
# Detect OS
# ---------------------------------------------------------
. /etc/os-release

if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
    DOCKER_OS="$ID"
else
    echo "Unsupported OS: $ID"
    exit 1
fi

echo "Detected OS: $PRETTY_NAME"

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
# Clean old Docker sources
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
# Add Docker GPG key
# ---------------------------------------------------------
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/$DOCKER_OS/gpg \
    -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# ---------------------------------------------------------
# Add Docker repository (.sources format)
# ---------------------------------------------------------
sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/$DOCKER_OS
Suites: $VERSION_CODENAME
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# ---------------------------------------------------------
# Install Docker Engine + CLI + plugins
# ---------------------------------------------------------
sudo apt update
sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# ---------------------------------------------------------
# Post-install message
# ---------------------------------------------------------
echo "Docker installed successfully."
echo "Run: sudo usermod -aG docker \$USER && newgrp docker"
