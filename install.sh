#!/usr/bin/env bash
#
# WeAllCode Laptop Setup
#
# To install:
#   /bin/bash -c "$(curl -fsSL wac.fyi/mac)"
#

set -e

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
  FLAKE_CONFIG="weallcode-laptop"
else
  FLAKE_CONFIG="weallcode-laptop-intel"
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
    # Official Nix installer for Intel Macs (Determinate dropped x86_64-darwin support)
    # Use Nix 2.18.1 for compatibility with macOS 12.x Monterey
    sh <(curl -L https://releases.nixos.org/nix/nix-2.18.1/install)
  fi

  # Source nix for current shell
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# Apply nix-darwin configuration
echo "Applying nix-darwin configuration..."
nix --extra-experimental-features "nix-command flakes" --option substituters "" run nix-darwin -- switch --flake "github:bottd/laptop?ref=nix#${FLAKE_CONFIG}"

echo "Setup complete! Restart your Mac for all changes to take effect."
