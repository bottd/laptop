#!/usr/bin/env bash
#
# WeAllCode Laptop Setup
#
# To install:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/bottd/laptop/nix/install.sh)"
#

set -e

# Detect architecture
ARCH=$(uname -m)
MACOS_VERSION=$(sw_vers -productVersion | cut -d. -f1)

echo "Detected: macOS $MACOS_VERSION on $ARCH"

if [ "$ARCH" = "arm64" ]; then
  HOME_CONFIG="weallcode@weallcode-laptop"
else
  HOME_CONFIG="weallcode@weallcode-laptop-intel"
fi

# Install Nix if not present
if ! command -v nix &>/dev/null; then
  echo "Installing Nix..."

  if [ "$ARCH" = "arm64" ]; then
    # Determinate installer for Apple Silicon
    curl -L https://github.com/DeterminateSystems/nix-installer/releases/latest/download/nix-installer-aarch64-darwin -o /tmp/nix-installer
    chmod +x /tmp/nix-installer
    /tmp/nix-installer install
    rm /tmp/nix-installer
  else
    # Official Nix installer for Intel Macs
    # Use Nix 2.18.1 for macOS 12.x compatibility
    if [ "$MACOS_VERSION" -lt 13 ]; then
      sh <(curl -L https://releases.nixos.org/nix/nix-2.18.1/install)
    else
      sh <(curl -L https://nixos.org/nix/install)
    fi
  fi

  # Source nix for current shell
  if [ -f '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  fi
fi

# Apply home-manager configuration
echo "Applying home-manager configuration..."
nix --extra-experimental-features "nix-command flakes" run home-manager -- switch --flake "github:bottd/laptop?ref=nix#${HOME_CONFIG}"

echo "Setup complete! Restart your terminal for all changes to take effect."
