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
# For macOS 12, we need to patch coreutils first
if [ "$MACOS_VERSION" -lt 13 ]; then
  echo "Patching coreutils for macOS 12 compatibility..."

  # Create a temporary overlay flake
  OVERLAY_DIR=$(mktemp -d)
  cat > "$OVERLAY_DIR/flake.nix" << 'OVERLAYEOF'
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-23.05-darwin";
  outputs = { nixpkgs, ... }: {
    packages.x86_64-darwin.coreutils =
      let pkgs = import nixpkgs {
        system = "x86_64-darwin";
        overlays = [(final: prev: {
          coreutils = prev.coreutils.overrideAttrs (old: {
            configureFlags = (old.configureFlags or []) ++ [
              "ac_cv_func_mkfifoat=no"
              "ac_cv_func_mknodat=no"
            ];
          });
        })];
      };
      in pkgs.coreutils;
  };
}
OVERLAYEOF

  # Build patched coreutils and add to profile
  nix --extra-experimental-features "nix-command flakes" profile install "$OVERLAY_DIR#coreutils" --option substitute false
  rm -rf "$OVERLAY_DIR"
fi

# Apply nix-darwin configuration
echo "Applying nix-darwin configuration..."
nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake "github:bottd/laptop?ref=nix#${FLAKE_CONFIG}"

echo "Setup complete! Restart your Mac for all changes to take effect."
