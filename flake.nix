{
  description = "We All Code - macOS laptop configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, treefmt-nix, ... }:
    let
      allSystems = [ "x86_64-darwin" "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs allSystems;
      forDarwin = nixpkgs.lib.genAttrs [ "x86_64-darwin" "aarch64-darwin" ];

      pythonOverlay = import ./modules/python.nix;

      pkgsFor = system: import nixpkgs {
        inherit system;
        overlays = [ pythonOverlay ];
      };
    in
    {
      packages = forDarwin (system:
        let
          pkgs = pkgsFor system;
          vscode = import ./modules/vscode.nix { inherit pkgs; };
          packages = import ./modules/packages.nix { inherit pkgs vscode; };
        in
        {
          default = pkgs.buildEnv {
            name = "weallcode-env";
            paths = packages;
          };

          vscode-settings = vscode.settings;

          python = pkgs.python3.withPackages (ps: [
            ps.tkinter
            ps.weallcode-robot
          ]);
        });

      devShells = forDarwin (system:
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
