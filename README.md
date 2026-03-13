# We All Code - Laptop Setup

NixOS configuration for classroom laptops (Intel MacBooks).

## Current Software

- XFCE Desktop
- VS Code with extensions:
  - Python and Pylance
  - Ruff (linter/formatter)
  - Prettier
- Firefox
- Python 3 with packages:
  - `tkinter`
  - `rich`
- [`weallcode-robot`](https://github.com/WeAllCode/tinybit-python) (installed via pip on update)
- git, curl

## Installation Steps

### 1. Download and Flash ISO

Download the ISO from the latest [GitHub Actions build artifact](../../actions/workflows/build-iso.yml). Flash it to a USB drive with `dd` or [Balena Etcher](https://etcher.balena.io/).

### 2. Boot from USB

Shut down the MacBook and insert the USB. Power it on while holding down the **Option** key. Select the USB drive on the boot menu.

### 3. Connect to WiFi

The installer boots into an XFCE desktop. To connect to WiFi open the network connection menu in the system tray. An internet connection is required for setup.

### 4. Install

Double-click the **Classroom Setup** shortcut on the desktop. This partitions the disk and runs `nixos-install` with the classroom flake config. The laptop will reboot when finished — do not remove the USB until the laptop reboots.

## Updating

Each laptop has a **Classroom Update** desktop shortcut. It updates the system to use the latest config on GitHub and upgrades `weallcode-robot` via pip.

## Development

To build a development environment you must install [Nix](https://nixos.org/download/) and [direnv](https://direnv.net/). Then from your `weallcode/laptop` directory run:

```sh
direnv allow
```

This will set up formatting, linting, and pre-commit hooks. You can run `nix fmt` to format all files.

## Project Structure

```
├── flake.nix                          Entry point
├── modules/
│   ├── base.nix                       System config
│   ├── disk.nix                       Partition layout (used by installer and config)
│   ├── iso.nix                        Installer ISO
│   ├── xfce.nix                       Classroom desktop environment
│   ├── vscode.nix                     VS Code extensions and settings
│   ├── python.nix                     Python interpreter and packages
│   ├── hardware-configuration.nix     Boot and kernel modules for Intel MacBooks
│   ├── broadcom.nix                   Broadcom WiFi driver for Intel MacBooks
│   ├── networkmanager.nix
│   └── nix-settings.nix
└── scripts/
    ├── machine-setup.py               Partition and install - shortcut on installer desktop
    └── update.py                      Update system and weallcode-robot - shortcut on classroom desktop
```
