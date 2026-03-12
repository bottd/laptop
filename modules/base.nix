{ pkgs, nixpkgs, lib, config, ... }:
let
  inherit (config.networking) hostName;
  vscode = import ./vscode.nix { inherit pkgs; };
  vscodeSettingsDir = "/home/student/.config/Code/User";
in
{
  imports = [
    ./hardware-configuration.nix
    "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
  ];

  config = {
    isoImage = {
      isoName = "${hostName}.iso";
      makeEfiBootable = true;
      makeUsbBootable = true;
      squashfsCompression = "zstd -Xcompression-level 6";
    };

    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
      tmp.cleanOnBoot = true;
    };

    # Auto-login student user
    users.users.student = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
      initialPassword = "weallcode";
    };

    # GNOME desktop
    services.xserver = {
      enable = true;
      displayManager.gdm = {
        enable = true;
        autoLogin.delay = 0;
      };
      desktopManager.gnome.enable = true;
    };

    services.displayManager.autoLogin = {
      enable = true;
      user = "student";
    };

    # Workaround for GNOME auto-login race condition
    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;

    services.openssh.enable = true;

    networking.networkmanager.enable = true;

    # Bluetooth
    hardware.bluetooth.enable = true;

    # Firmware handled by hardware-configuration.nix (enableRedistributableFirmware + broadcom-sta)

    # Packages
    environment.systemPackages = with pkgs; [
      # CLI
      git
      curl
      direnv

      # Python
      tk
      tcl
      (python3.withPackages (ps: [
        ps.tkinter
        ps.weallcode-robot
      ]))

      # GUI
      vscode.package
      google-chrome

      # System
      usbutils
      pciutils
    ];

    # VS Code settings - deployed to student home
    system.activationScripts.vscodeSettings = ''
      mkdir -p "${vscodeSettingsDir}"
      cp ${vscode.settings} "${vscodeSettingsDir}/settings.json"
      chown -R student:users "${vscodeSettingsDir}"
    '';

    # Wallpaper via GNOME settings
    environment.etc."weallcode-background.png".source = ../weallcode-background.png;

    # GNOME defaults for student
    programs.dconf.profiles.user.databases = [{
      settings = {
        "org/gnome/desktop/background" = {
          picture-uri = "file:///etc/weallcode-background.png";
          picture-uri-dark = "file:///etc/weallcode-background.png";
        };
        "org/gnome/desktop/screensaver" = {
          lock-enabled = false;
        };
        "org/gnome/desktop/session" = {
          idle-delay = lib.gvariant.mkUint32 0;
        };
        "org/gnome/shell" = {
          favorite-apps = [
            "google-chrome.desktop"
            "code.desktop"
            "org.gnome.Terminal.desktop"
          ];
        };
      };
    }];

    powerManagement.cpuFreqGovernor = "ondemand";

    nix = {
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;
        substituters = [ "https://nix-community.cachix.org" ];
        trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
      };
      gc.automatic = true;
    };

    system.stateVersion = "25.05";
  };
}
