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
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

  # Source nix for current shell
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# Apply nix-darwin configuration
echo "Applying nix-darwin configuration..."
nix run nix-darwin -- switch --flake "github:bottd/laptop?ref=nix#${FLAKE_CONFIG}"

echo "Setup complete! Restart your Mac for all changes to take effect."
