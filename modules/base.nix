{ pkgs, ... }: {
  networking.hostName = "classroom";

  imports = [
    ./hardware-configuration.nix
    ./networkmanager.nix
    ./xfce.nix
    ./python.nix
    ./nix-settings.nix
  ];

  boot = {
    tmp.cleanOnBoot = true;
    kernel.sysctl."fs.inotify.max_user_watches" = 524288;
  };

  users.users.weallcode = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    hashedPassword = "$6$Ht9D0BQqUbhyS1x2$NIs9RdE4wj9y1nIu3dxmVTS7aNtsl41D0D7rAtxkXxwIb3aKBqsvlA7gY9JSTyRTT.T0xJV7XBEZHiLpXCuVv/";
  };

  system.activationScripts.setupHomeManagerProfileDir.text = ''
    install -d -m 0755 -o weallcode -g users /nix/var/nix/profiles/per-user/weallcode
  '';

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  hardware.bluetooth.enable = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    direnv
    jetbrains-mono
    noto-fonts-color-emoji
    firefox
    usbutils
    pciutils

    (pkgs.writeScriptBin "classroom-update" (builtins.readFile ../scripts/update.py))
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    users.weallcode = _: {
      home.stateVersion = "25.11";
      imports = [ ../modules/vscode.nix ];

      home.file."Desktop/classroom-update.desktop" = {
        text = ''
          [Desktop Entry]
          Name=Classroom Update
          Comment=Pull latest config and rebuild the system
          Exec=xfce4-terminal --hold -e "classroom-update"
          Icon=system-software-update
          Terminal=false
          Type=Application
        '';
        executable = true;
      };

    };
  };

  powerManagement.cpuFreqGovernor = "ondemand";

  system.stateVersion = "25.11";
}
