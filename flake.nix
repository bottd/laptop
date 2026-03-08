{
  description = "We All Code - Linux laptop configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, treefmt-nix, ... }:
    let
      allSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs allSystems;

      pythonOverlay = import ./modules/python.nix;

      pkgsFor = system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ pythonOverlay ];
        };

      mkHome = system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor system;
          modules = [ ./home.nix ];
        };
    in {
      homeConfigurations = {
        "weallcode" = mkHome "x86_64-linux";
        "weallcode-arm" = mkHome "aarch64-linux";
      };

      devShells = forAllSystems (system:
        let pkgs = pkgsFor system;
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [
              git
              direnv
              (python3.withPackages (ps: [ ps.tkinter ps.weallcode-robot ]))
            ];
          };
        });

      formatter = forAllSystems (system:
        (treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
          programs.shfmt.enable = true;
          programs.prettier.enable = true;
        }).config.build.wrapper);
    };
}
