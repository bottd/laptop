{
  description = "We All Code - macOS laptop packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
  };

  outputs = { nixpkgs, ... }:
    let
      forDarwin = nixpkgs.lib.genAttrs [ "x86_64-darwin" "aarch64-darwin" ];
    in
    {
      packages = forDarwin (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
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
        }
      );
    };
}
