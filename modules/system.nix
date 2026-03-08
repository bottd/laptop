{
  pkgs,
  lib,
  nixpkgs-unstable,
  ...
}:

let
  unstablePkgs = import nixpkgs-unstable { system = pkgs.system; };
in
{
  # Use uutils-coreutils (Rust) instead of GNU coreutils for macOS 12.x compatibility
  nixpkgs.overlays = [
    (final: prev: {
      coreutils = unstablePkgs.uutils-coreutils;
    })
  ];
  services.nix-daemon.enable = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # Disable binary cache - force source builds for macOS 12.x compatibility
    substituters = [ ];
    trusted-public-keys = [ ];
  };

  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 0;
      Hour = 2;
      Minute = 0;
    };
    options = "--delete-older-than 30d";
  };

  environment.systemPackages = with pkgs; [
    git
    (python3.withPackages (ps: [ ps.tkinter ]))
    vim
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  system.defaults = {
    loginwindow = {
      GuestEnabled = false;
      autoLoginUser = null;
    };
    dock = {
      autohide = false;
      show-process-indicators = true;
      show-recents = false;
      orientation = "bottom";
    };
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      ShowStatusBar = true;
    };
  };

  system.activationScripts.postActivation.text = ''
    # Set wallpaper for all desktops
    osascript -e 'tell application "System Events" to tell every desktop to set picture to "${../weallcode-background.png}"'
  '';
}
