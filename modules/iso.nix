{ config, pkgs, diskoPackage, ... }:
let
  inherit (config.networking) hostName;
in
{
  imports = [
    ./broadcom.nix
    ./networkmanager.nix
    ./nix-settings.nix
    ./python.nix
  ];

  networking.hostName = "weallcode";

  config = {
    image.fileName = "${hostName}-installer.iso";
    isoImage = {
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

      (pkgs.writeScriptBin "classroom-setup" (builtins.readFile ../scripts/machine-setup.py))
    ];

    system.activationScripts.installDesktopShortcut =
      let
        desktopFile = pkgs.writeText "classroom-setup.desktop" ''
          [Desktop Entry]
          Name=Classroom Setup
          Comment=Wipe disk and install NixOS classroom config
          Exec=xfce4-terminal --hold -e "sudo classroom-setup"
          Icon=system-software-install
          Terminal=false
          Type=Application
        '';
      in
      ''
        mkdir -p /home/nixos/Desktop
        cp ${desktopFile} /home/nixos/Desktop/classroom-setup.desktop
        chmod +x /home/nixos/Desktop/classroom-setup.desktop
        chown -R nixos:users /home/nixos/Desktop
      '';

    users.users.nixos = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
      hashedPassword = "$6$Ht9D0BQqUbhyS1x2$NIs9RdE4wj9y1nIu3dxmVTS7aNtsl41D0D7rAtxkXxwIb3aKBqsvlA7gY9JSTyRTT.T0xJV7XBEZHiLpXCuVv/";
    };

    security.sudo.wheelNeedsPassword = false;

    system.stateVersion = "25.11";
  };
}
