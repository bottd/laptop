#!/usr/bin/env python3

import subprocess

from rich.console import Console
from rich.panel import Panel

console = Console()

FLAKE_REF = "git+https://github.com/WeAllCode/laptop.git#classroom"
ROBOT_PKG = "git+https://github.com/WeAllCode/tinybit-python.git"


def main():
    console.print()
    console.print(
        Panel.fit(
            "[bold]We All Code[/bold] — Updater",
            subtitle="[dim]weallcode.org[/dim]",
        )
    )
    console.print()

    console.rule("Rebuilding")
    subprocess.run(
        ["sudo", "nixos-rebuild", "switch", "--refresh", "--flake", FLAKE_REF],
        check=True,
    )

    console.rule("Installing weallcode-robot")
    subprocess.run(
        ["pip", "install", "--user", "--upgrade", ROBOT_PKG],
        check=True,
    )

    console.print()
    console.print(
        Panel.fit(
            "[bold green]Done![/bold green] System updated.",
            border_style="green",
        )
    )
    console.print()
    input("Press Enter to close...")


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as error:
        console.print(f"\n[bold red]Update failed.[/bold red]\n{error}\n")
        input("Press Enter to close...")
        raise SystemExit(1)
