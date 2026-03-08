# We All Code - Laptop Setup

macOS configuration for kids coding class using nix-darwin.

## Prerequisites

- macOS with admin account configured
- Internet connection

## Installation

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/bottd/laptop/nix/install.sh)"
```

## Updating

```bash
darwin-rebuild switch --flake github:bottd/laptop?ref=nix
```

## What Gets Installed

- Git
- Python 3 (with tkinter)
- Vim
- direnv

## What Gets Configured

- Nix with flakes enabled
- Zsh with completion
- Finder: show extensions, path bar, status bar
- Dock: no recent apps
