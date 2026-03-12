{ lib, modulesPath, ... }: {
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
  ];

  # Intel MacBook boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sdhci_pci"
  ];

  boot.kernelModules = [ "kvm-intel" "wl" ];

  # Intel GPU
  hardware.graphics.enable = true;

  # Broadcom WiFi + Bluetooth (Intel MacBooks use BCM4331, BCM43xx chips)
  hardware.broadcom-sta.enable = lib.mkDefault true;
  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.allowUnfree = true;
}
