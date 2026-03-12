{ inputs, ... }:
let
  pythonOverlay = import ../modules/python.nix;

  hosts = {
    weallcode = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit (inputs) nixpkgs; };
      modules = [
        ../hosts/weallcode/configuration.nix
        { nixpkgs.overlays = [ pythonOverlay ]; }
      ];
    };
  };

in
{
  flake = {
    nixosConfigurations = hosts;
    packages.x86_64-linux = {
      weallcode = hosts.weallcode.config.system.build.isoImage;
      default = hosts.weallcode.config.system.build.isoImage;
    };
  };
}
