# Broadcom BCM4360 WiFi + Bluetooth (MacBook Air A1466)
# Shared between installer ISO and installed system
{ config, lib, ... }: {
  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowInsecurePredicate = pkg: lib.getName pkg == "broadcom-sta";
  boot.kernelModules = [ "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.blacklistedKernelModules = [ "b43" "bcma" ];
}
