{
  description = "We All Code - macOS laptop packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, treefmt-nix, ... }:
    let
      allSystems =
        [ "x86_64-darwin" "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs allSystems;
      forDarwin = nixpkgs.lib.genAttrs [ "x86_64-darwin" "aarch64-darwin" ];

      mkHome = system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          modules = [
            ./home.nix
            {
              home.username = "weallcode";
              home.homeDirectory = "/Users/weallcode";
            }
          ];
        };
    in {
      # Simple package env (fallback)
      packages = forDarwin (system:
        let
          pkgs = import nixpkgs { inherit system; };
          weallcode-robot = pkgs.python3Packages.buildPythonPackage rec {
            pname = "weallcode_robot";
            version = "3.1.4";
            src = pkgs.fetchPypi {
              inherit pname version;
              hash = "sha256-f+CR7eRC3XmBlEh/gPPsC3bDCZZtTvkxaJ56ehhr/8k=";
            };
            propagatedBuildInputs = with pkgs.python3Packages; [ bleak ];
            doCheck = false;
          };
        in {
          default = pkgs.buildEnv {
            name = "weallcode-env";
            paths = with pkgs; [
              git
              direnv
              tk
              tcl
              (python3.withPackages (ps: [ ps.tkinter weallcode-robot ]))
            ];
          };
        });

      # Home-manager configs
      homeConfigurations = {
        "weallcode@aarch64-darwin" = mkHome "aarch64-darwin";
        "weallcode@x86_64-darwin" = mkHome "x86_64-darwin";
      };

      formatter = forAllSystems (system:
        (treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
          programs.shfmt.enable = true;
          programs.prettier.enable = true;
        }).config.build.wrapper);
    };
}
