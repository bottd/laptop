{ nixpkgs, config, pkgs, diskoPackage, ... }:
let
  inherit (config.networking) hostName;
in
{
  imports = [
    "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
    "${nixpkgs}/nixos/modules/profiles/all-hardware.nix"
    ./broadcom.nix
  ];

  config = {
    isoImage = {
      isoName = "${hostName}-installer.iso";
      makeEfiBootable = true;
      makeUsbBootable = true;
      squashfsCompression = "zstd -Xcompression-level 6";
    };

    services.xserver.enable = true;
    services.xserver.desktopManager.xfce.enable = true;
    services.displayManager.autoLogin = {
      enable = true;
      user = "nixos";
    };

    environment.systemPackages = with pkgs; [
      git
      vim
      diskoPackage
      (python3.withPackages (ps: [ ps.rich ]))

      (pkgs.writeScriptBin "weallcode-install" (builtins.readFile ../scripts/machine-setup.py))
    ];

    system.activationScripts.installDesktopShortcut =
      let
        desktopFile = pkgs.writeText "weallcode-install.desktop" ''
          [Desktop Entry]
          Name=Install We All Code
          Comment=Wipe disk and install NixOS classroom config
          Exec=xfce4-terminal --hold -e "sudo weallcode-install"
          Icon=system-software-install
          Terminal=false
          Type=Application
        '';
      in
      ''
        mkdir -p /home/nixos/Desktop
        cp ${desktopFile} /home/nixos/Desktop/weallcode-install.desktop
        chmod +x /home/nixos/Desktop/weallcode-install.desktop
        chown -R nixos:users /home/nixos/Desktop
      '';

    networking.networkmanager.enable = true;
    networking.wireless.enable = false;

    # Store WiFi passwords system-wide (no secret service needed)
    networking.networkmanager.settings."connection-wifi" = {
      "match-device" = "type:wifi";
      "connection.permissions" = "";
    };

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    users.users.nixos = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
      initialPassword = "nixos";
    };

    security.sudo.wheelNeedsPassword = false;
  };
}
