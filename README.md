# We All Code - Laptop Setup

NixOS configuration for classroom laptops (Intel MacBooks).

## Installation Steps

### 1. Download ISO

Download the ISO from the latest [GitHub Actions build artifact](../../actions/workflows/build-iso.yml). Once downloaded, flash to installation USB.

### 2. Boot from USB

Boots into a XFCE desktop. Connect to WiFi.

### 3. Apply classroom config

Double-click the **We All Code Install** shortcut on the desktop. This runs `nixos-install` with the classroom flake config.

## What's Included

- XFCE Desktop
- VS Code with Python and Pylance extensions
- Google Chrome
- Python 3 with `tkinter` and `weallcode-robot`
