{ inputs, ... }:
let
  pythonOverlay = import ../modules/python-overlay.nix;

  hosts = {
    laptop = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.disko.nixosModules.disko
        inputs.home-manager.nixosModules.home-manager
        ../modules/disk.nix
        ../modules/base.nix
        {
          networking.hostName = "laptop";
          nixpkgs.overlays = [ pythonOverlay ];
        }
      ];
    };
  };

  installer = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit (inputs) nixpkgs;
      diskoPackage = inputs.disko.packages.x86_64-linux.disko;
    };
    modules = [
      ../modules/iso.nix
      { networking.hostName = "weallcode"; }
    ];
  };

in
{
  flake = {
    nixosConfigurations = hosts;
    packages.x86_64-linux.default = installer.config.system.build.isoImage;
  };
}
