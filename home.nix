{ pkgs, ... }:

let
  weallcode-robot = pkgs.python3Packages.buildPythonPackage rec {
    pname = "weallcode_robot";
    version = "3.1.4";
    src = pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-f+CR7eRC3XmBlEh/gPPsC3bDCZZtTvkxaJ56ehhr/8k=";
    };
    propagatedBuildInputs = with pkgs.python3Packages; [ bleak ];
    doCheck = false;
  };
in
{
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    git
    direnv
    tk
    tcl
    (python3.withPackages (ps: [ ps.tkinter weallcode-robot ]))
  ];

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      eval "$(direnv hook zsh)"
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = { enable = true; };

  # VS Code settings
  home.file."Library/Application Support/Code/User/settings.json".source =
    ./vscode-settings.json;

  # Wallpaper
  home.file.".weallcode-background.png".source = ./weallcode-background.png;

  home.activation.setWallpaper = ''
    /usr/bin/osascript -e 'tell application "System Events" to tell every desktop to set picture to POSIX file "'$HOME'/.weallcode-background.png"' || true
  '';
}
