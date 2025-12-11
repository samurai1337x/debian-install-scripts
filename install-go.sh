#!/bin/bash
set -e

GO_VERSION="1.21.0"
GO_INSTALL_DIR="/usr/local/go"

echo "---------------------------------------------------------"
echo "Installing Go (Golang)..."
echo "---------------------------------------------------------"

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" == "x86_64" ]; then
    GO_ARCH="amd64"
elif [[ "$ARCH" == "arm"* || "$ARCH" == "aarch64" ]]; then
    GO_ARCH="arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Remove previous Go installation
if [ -d "$GO_INSTALL_DIR" ]; then
    echo "Removing previous Go installation..."
    sudo rm -rf "$GO_INSTALL_DIR"
fi

# Download Go
GO_TAR="go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
echo "Downloading Go $GO_VERSION..."
curl -LO "https://go.dev/dl/$GO_TAR"

# Extract Go
echo "Extracting Go..."
sudo tar -C /usr/local -xzf "$GO_TAR"
rm "$GO_TAR"

# Add Go to PATH in ~/.profile if not already added
if ! grep -q 'export PATH=$PATH:/usr/local/go/bin' ~/.profile; then
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
fi

# Create system-wide symlinks
sudo ln -sf /usr/local/go/bin/go /usr/bin/go
sudo ln -sf /usr/local/go/bin/gofmt /usr/bin/gofmt

echo "---------------------------------------------------------"
echo "Go installation complete!"
echo "Installed version: $(/usr/local/go/bin/go version)"
echo "You can now use Go by typing 'go' in the terminal."
echo "To use Go in new terminals, run: source ~/.profile"
echo "---------------------------------------------------------"
