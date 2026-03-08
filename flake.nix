{
  description = "We All Code - macOS laptop packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, treefmt-nix, ... }:
    let
      allSystems =
        [ "x86_64-darwin" "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs allSystems;
      forDarwin = nixpkgs.lib.genAttrs [ "x86_64-darwin" "aarch64-darwin" ];
    in {
      packages = forDarwin (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.buildEnv {
            name = "weallcode-env";
            paths = with pkgs; [
              git
              vim
              direnv
              tk
              tcl
              (python3.withPackages (ps: [ ps.tkinter ]))
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
