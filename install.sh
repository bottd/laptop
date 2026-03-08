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
    NIX_INSTALLER_URL="https://github.com/DeterminateSystems/nix-installer/releases/latest/download/nix-installer-aarch64-darwin"
  else
    NIX_INSTALLER_URL="https://github.com/DeterminateSystems/nix-installer/releases/latest/download/nix-installer-x86_64-darwin"
  fi

  curl -L "$NIX_INSTALLER_URL" -o /tmp/nix-installer
  chmod +x /tmp/nix-installer
  /tmp/nix-installer install
  rm /tmp/nix-installer

  # Source nix for current shell
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# Apply nix-darwin configuration
echo "Applying nix-darwin configuration..."
nix run nix-darwin -- switch --flake "github:bottd/laptop?ref=nix#${FLAKE_CONFIG}"

echo "Setup complete! Restart your Mac for all changes to take effect."
