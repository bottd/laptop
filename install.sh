#!/usr/bin/env bash
#
# WeAllCode Laptop Setup
#
# To install:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/bottd/laptop/nix/install.sh)"
#

set -e

GITHUB_REPO="https://raw.githubusercontent.com/bottd/laptop/nix"

# Detect architecture
ARCH=$(uname -m)
MACOS_VERSION=$(sw_vers -productVersion | cut -d. -f1)

echo "Detected: macOS $MACOS_VERSION on $ARCH"

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

# Clean up existing profiles
echo "Cleaning up existing profiles..."
nix --extra-experimental-features "nix-command flakes" profile wipe-history 2>/dev/null || true
for i in $(seq 0 20); do
  nix --extra-experimental-features "nix-command flakes" profile remove "$i" 2>/dev/null || true
done

# Determine home-manager config name
if [ "$ARCH" = "arm64" ]; then
  HM_CONFIG="weallcode@aarch64-darwin"
else
  HM_CONFIG="weallcode@x86_64-darwin"
fi

# Try home-manager first, fall back to simple profile
echo "Applying home-manager configuration..."
if nix --extra-experimental-features "nix-command flakes" run home-manager -- switch --no-write-lock-file --flake "github:bottd/laptop?ref=nix#${HM_CONFIG}" 2>/dev/null; then
  echo "Home-manager configuration applied successfully!"
else
  echo "Home-manager failed, falling back to simple profile..."
  nix --extra-experimental-features "nix-command flakes" profile install --no-write-lock-file "github:bottd/laptop?ref=nix"
fi

# Install VS Code and Chrome via Homebrew casks (Nix casks are problematic on macOS)
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew for GUI apps..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ "$ARCH" = "arm64" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

brew install --cask google-chrome visual-studio-code 2>/dev/null || true

# Set wallpaper
echo "Setting wallpaper..."
curl -fsSL "$GITHUB_REPO/weallcode-background.png" -o "$HOME/.weallcode-background.png"
osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$HOME/.weallcode-background.png\""

# Configure Dock
echo "Configuring Dock..."
if command -v dockutil &>/dev/null; then
  dockutil --remove all \
    --add /Applications/Google\ Chrome.app \
    --add /Applications/Visual\ Studio\ Code.app 2>/dev/null || true
else
  brew install dockutil 2>/dev/null || true
  dockutil --remove all \
    --add /Applications/Google\ Chrome.app \
    --add /Applications/Visual\ Studio\ Code.app 2>/dev/null || true
fi

# Setup direnv in shell
echo "Configuring shell..."
if ! grep -q 'direnv hook' "$HOME/.zshrc" 2>/dev/null; then
  echo 'eval "$(direnv hook zsh)"' >>"$HOME/.zshrc"
fi

echo "Setup complete! Restart your terminal for all changes to take effect."
