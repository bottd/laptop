#!/usr/bin/env python3

import subprocess

from rich.console import Console
from rich.panel import Panel

console = Console()

FLAKE_REF = "git+https://github.com/WeAllCode/laptop.git#classroom"


def main():
    console.print()
    console.print(
        Panel.fit(
            "[bold]We All Code[/bold] — Installer",
            subtitle="[dim]weallcode.org[/dim]",
        )
    )
    console.print()
    console.print("[bold red]This will ERASE the disk and install NixOS.[/bold red]")
    console.print()

    console.print("[bold yellow]Press Enter to wipe and install...[/bold yellow]")
    input()

    console.rule("Partitioning")
    subprocess.run(
        ["disko", "--flake", FLAKE_REF, "--mode", "destroy,format,mount"],
        check=True,
    )

    console.rule("Installing")
    subprocess.run(
        [
            "nixos-install",
            "--root",
            "/mnt",
            "--flake",
            FLAKE_REF,
            "--no-root-password",
        ],
        check=True,
    )

    console.rule("Unmounting")
    subprocess.run(["umount", "-R", "/mnt"], check=True)

    console.print()
    console.print(
        Panel.fit(
            "[bold green]Done![/bold green] Remove USB and reboot.",
            border_style="green",
        )
    )
    console.print()
    input("Press Enter to reboot...")
    subprocess.run(["reboot"], check=True)


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as error:
        console.print(f"\n[bold red]Install failed.[/bold red]\n{error}\n")
        input("Press Enter to close...")
        raise SystemExit(1)
