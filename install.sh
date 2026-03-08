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
    # For Intel Macs on older macOS, use Nix 2.13.6 (last version before SDK issues)
    if [ "$MACOS_VERSION" -lt 13 ]; then
      sh <(curl -L https://releases.nixos.org/nix/nix-2.13.6/install)
    else
      sh <(curl -L https://releases.nixos.org/nix/nix-2.18.1/install)
    fi
  fi

  # Source nix for current shell
  if [ -f '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  fi
fi

# Apply nix-darwin configuration
echo "Applying nix-darwin configuration..."
# Force source builds on macOS 12 to use local SDK
if [ "$MACOS_VERSION" -lt 13 ]; then
  nix --extra-experimental-features "nix-command flakes" --option substitute false run nix-darwin -- switch --flake "github:bottd/laptop?ref=nix#${FLAKE_CONFIG}"
else
  nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake "github:bottd/laptop?ref=nix#${FLAKE_CONFIG}"
fi

echo "Setup complete! Restart your Mac for all changes to take effect."
