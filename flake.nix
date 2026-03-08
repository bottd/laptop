{
  description = "We All Code - macOS laptop configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-22.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      nix-darwin,
      treefmt-nix,
      ...
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      mkDarwin =
        platform:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit nixpkgs-unstable; };
          modules = [
            ./modules/system.nix
            {
              nixpkgs.hostPlatform = platform;
              networking.hostName = "weallcode-laptop";
              system.stateVersion = 5;
            }
          ];
        };
    in
    {
      darwinConfigurations = {
        weallcode-laptop = mkDarwin "aarch64-darwin";
        weallcode-laptop-intel = mkDarwin "x86_64-darwin";
      };

      formatter = forAllSystems (
        system:
        (treefmt-nix.lib.evalModule nixpkgs-unstable.legacyPackages.${system} {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
          programs.shfmt.enable = true;
          programs.prettier.enable = true;
        }).config.build.wrapper
      );
    };
}
