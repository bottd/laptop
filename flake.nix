{
  description = "We All Code - macOS laptop configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-23.05-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
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
        (treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
          programs.shfmt.enable = true;
          programs.prettier.enable = true;
        }).config.build.wrapper
      );
    };
}
