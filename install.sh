#!/usr/bin/env bash
#
# WeAllCode Laptop Setup
#
# To install:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/bottd/laptop/nix/install.sh)"
#

set -e

GITHUB_REPO="https://raw.githubusercontent.com/bottd/laptop/nix"
ARCH=$(uname -m)
MACOS_VERSION=$(sw_vers -productVersion | cut -d. -f1)

echo "Detected: macOS $MACOS_VERSION on $ARCH"

#
# 1. Install Nix
#
if ! command -v nix &>/dev/null; then
  echo "Installing Nix..."
  if [ "$ARCH" = "arm64" ]; then
    curl -L https://github.com/DeterminateSystems/nix-installer/releases/latest/download/nix-installer-aarch64-darwin -o /tmp/nix-installer
    chmod +x /tmp/nix-installer
    /tmp/nix-installer install
    rm /tmp/nix-installer
  else
    [ "$MACOS_VERSION" -lt 13 ] && NIX_URL="https://releases.nixos.org/nix/nix-2.18.1/install" || NIX_URL="https://nixos.org/nix/install"
    sh <(curl -L "$NIX_URL")
  fi
  [ -f '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ] && . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

#
# 2. Install Nix packages from flake
#
echo "Installing Nix packages..."
nix --extra-experimental-features "nix-command flakes" profile remove '.*' 2>/dev/null || true
nix --extra-experimental-features "nix-command flakes" profile install --no-write-lock-file "github:bottd/laptop?ref=nix"

#
# 3. macOS-specific setup (can't be done in Nix without nix-darwin)
#

# Homebrew for GUI apps
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  [ "$ARCH" = "arm64" ] && eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(/usr/local/bin/brew shellenv)"
fi

echo "Installing GUI apps..."
brew install --cask google-chrome visual-studio-code 2>/dev/null || true

echo "Installing VS Code extensions..."
code --install-extension ms-python.python --force 2>/dev/null || true
code --install-extension ms-python.vscode-pylance --force 2>/dev/null || true

# VS Code settings
mkdir -p "$HOME/Library/Application Support/Code/User"
curl -fsSL "$GITHUB_REPO/vscode-settings.json" -o "$HOME/Library/Application Support/Code/User/settings.json" 2>/dev/null || true

# Wallpaper
echo "Setting wallpaper..."
curl -fsSL "$GITHUB_REPO/weallcode-background.png" -o "$HOME/.weallcode-background.png"
osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$HOME/.weallcode-background.png\"" 2>/dev/null || true

# Dock
echo "Configuring Dock..."
command -v dockutil &>/dev/null || brew install dockutil 2>/dev/null || true
dockutil --remove all --add /Applications/Google\ Chrome.app --add /Applications/Visual\ Studio\ Code.app 2>/dev/null || true

# Shell
grep -q 'direnv hook' "$HOME/.zshrc" 2>/dev/null || echo 'eval "$(direnv hook zsh)"' >> "$HOME/.zshrc"

echo "Done! Restart your terminal."
