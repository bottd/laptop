{ pkgs, ... }:

{
  imports = [
    ./modules/python.nix
    ./modules/vscode.nix
    ./modules/shell.nix
    ./modules/desktop.nix
  ];

  home.stateVersion = "24.11";

  home.packages = with pkgs; [ git ];

  programs.home-manager.enable = true;

  programs.git = { enable = true; };
}
