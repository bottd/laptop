{ pkgs, ... }:

{
  imports = [
    ./modules/shell.nix
    ./modules/vscode.nix
    ./modules/desktop.nix
  ];

  home.username = "weallcode";
  home.homeDirectory = "/home/weallcode";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    # CLI tools
    git
    direnv

    # Python with packages
    tk
    tcl
    (python3.withPackages (ps: [
      ps.tkinter
      ps.weallcode-robot
    ]))

    # GUI apps
    google-chrome
  ];

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
  };
}
