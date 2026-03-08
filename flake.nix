{
  description = "We All Code - macOS laptop configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      treefmt-nix,
      ...
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      mkHome = system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          modules = [
            ./modules/home.nix
            {
              home.username = "weallcode";
              home.homeDirectory = "/Users/weallcode";
            }
          ];
        };
    in
    {
      homeConfigurations = {
        "weallcode@weallcode-laptop" = mkHome "aarch64-darwin";
        "weallcode@weallcode-laptop-intel" = mkHome "x86_64-darwin";
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
