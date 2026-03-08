{ pkgs, ... }:

{
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    git
    direnv
    tk
    tcl
    (python3.withPackages (ps: [ ps.tkinter ]))
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
