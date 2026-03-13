{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./xfce.nix
    ./python.nix
    ./nix-settings.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages;
    tmp.cleanOnBoot = true;
    kernel.sysctl."fs.inotify.max_user_watches" = 524288;
  };

  users.users.weallcode = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    initialPassword = "Coder4Life!";
  };

  networking.networkmanager.enable = true;

  # Store WiFi passwords system-wide (no secret service needed)
  networking.networkmanager.settings."connection-wifi" = {
    "match-device" = "type:wifi";
    "connection.permissions" = "";
  };

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
    google-chrome
    usbutils
    pciutils
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.weallcode = _: {
      home.stateVersion = "25.11";
      imports = [ ../modules/vscode.nix ];
    };
  };

  powerManagement.cpuFreqGovernor = "ondemand";

  system.stateVersion = "25.11";
}
