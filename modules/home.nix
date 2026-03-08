{ pkgs, ... }:

{
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    git
    vim
    (python3.withPackages (ps: [ ps.tkinter ]))
  ];

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Set wallpaper
  home.file.".weallcode-background.png".source = ../weallcode-background.png;

  home.activation.setWallpaper = ''
    /usr/bin/osascript -e 'tell application "System Events" to tell every desktop to set picture to "$HOME/.weallcode-background.png"'
  '';
}
