#!/usr/bin/env bash
#
# WeAllCode Laptop Setup (Linux)
#
# To install:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/bottd/laptop/nix/install.sh)"
#

set -e

ARCH=$(uname -m)
echo "Detected: Linux on $ARCH"

#
# 1. Install Nix
#
if ! command -v nix &>/dev/null; then
  echo "Installing Nix..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

#
# 2. Apply home-manager configuration
#
echo "Applying home-manager configuration..."

if [ "$ARCH" = "aarch64" ]; then
  HM_CONFIG="weallcode-arm"
else
  HM_CONFIG="weallcode"
fi

nix run home-manager -- switch --flake "github:bottd/laptop?ref=nix#${HM_CONFIG}"

echo "Done! Restart your terminal."
