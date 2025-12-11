#!/usr/bin/env bash

# ---------------------------------------------------------
# Remove conflicting or legacy Python packages (optional)
# ---------------------------------------------------------
CONFLICT_PKGS=$(dpkg --get-selections \
    python python2 python2-minimal python2.7 python-pip 2>/dev/null | cut -f1)

if [ -n "$CONFLICT_PKGS" ]; then
    echo "Removing conflicting Python packages: $CONFLICT_PKGS"
    sudo apt remove -y $CONFLICT_PKGS
fi

# ---------------------------------------------------------
# Clean previous custom Python repos (if any)
# ---------------------------------------------------------
sudo rm -f /etc/apt/sources.list.d/deadsnakes.list
sudo rm -f /etc/apt/sources.list.d/deadsnakes.sources
sudo rm -f /etc/apt/keyrings/deadsnakes.asc

# ---------------------------------------------------------
# Update apt and install prerequisites
# ---------------------------------------------------------
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

# ---------------------------------------------------------
# Load OS info
# ---------------------------------------------------------
. /etc/os-release

# ---------------------------------------------------------
# Detect architecture (amd64 / arm64 / others)
# ---------------------------------------------------------
ARCH=$(dpkg --print-architecture)
echo "Detected architecture: $ARCH"

# ---------------------------------------------------------
# Install Python development packages
# ---------------------------------------------------------
sudo apt update
sudo apt install -y \
    python3 \
    python3-full \
    python3-pip \
    python3-venv \
    python3-setuptools \
    python3-wheel \
    python3-virtualenv \
    build-essential \
    idle  # GUI shell

# ---------------------------------------------------------
# Upgrade pip, setuptools, wheel safely in user environment
# ---------------------------------------------------------
python3 -m pip install --upgrade --user pip setuptools wheel || true

# ---------------------------------------------------------
echo "---------------------------------------------------------"
echo "Python installation complete!"
echo "Installed:"
echo " - Python3"
echo " - pip3"
echo " - venv / virtualenv"
echo " - dev tools (headers, setuptools, wheel)"
echo " - build-essential (gcc, g++, make)"
echo " - idle (Python GUI shell)"
echo "---------------------------------------------------------"
echo "You can now create virtual environments with:"
echo "  python3 -m venv myenv"
echo "and activate them with:"
echo "  source myenv/bin/activate"
echo "To make 'python' point to 'python3', run:"
echo "sudo ln -s /usr/bin/python3 /usr/bin/python"
