#!/usr/bin/env python3

import os
import subprocess

from rich.console import Console
from rich.panel import Panel

console = Console()

REPO_URL = "https://github.com/bottd/laptop.git"
FLAKE_DIR = os.path.expanduser("~/laptop")
DISK = "/dev/sda"


def run(command):
    console.print(f"  [dim]$ {command}[/dim]")
    subprocess.run(command, shell=True, check=True)


def main():
    console.print()
    console.print(
        Panel.fit(
            "[bold]We All Code[/bold] — NixOS Installer",
            subtitle="[dim]weallcode.org[/dim]",
        )
    )
    console.print()
    console.print(
        "[bold red]This will ERASE the entire disk and install NixOS.[/bold red]"
    )
    console.print()

    console.print(f"[bold]Target disk:[/bold] {DISK}")
    run(f"lsblk {DISK}")
    console.print()

    console.print(
        "[bold yellow]Press Enter to wipe this disk and install...[/bold yellow]"
    )
    input()

    console.rule("Fetching configuration")
    try:
        run(f"git clone --depth 1 {REPO_URL} {FLAKE_DIR}")
    except subprocess.CalledProcessError:
        run(f"git -C {FLAKE_DIR} pull --ff-only")

    os.chdir(FLAKE_DIR)

    console.rule(f"Partitioning and formatting {DISK}")
    run("disko --mode destroy,format,mount modules/disk.nix")

    console.rule("Installing NixOS")
    console.print("[dim]This downloads packages — may take 15-30 min...[/dim]")
    run("nixos-install --root /mnt --flake .#laptop --no-root-password")

    console.rule("Unmounting")
    run("umount -R /mnt")

    console.print()
    console.print(
        Panel.fit(
            "[bold green]DONE![/bold green] Remove the USB drive and reboot.",
            border_style="green",
        )
    )
    console.print()
    input("Press Enter to reboot...")
    run("reboot")


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as error:
        console.print(f"\n[bold red]ERROR:[/bold red] Install failed!\n{error}\n")
        input("Press Enter to close...")
        raise SystemExit(1)
