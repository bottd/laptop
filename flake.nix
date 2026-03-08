{
  description = "We All Code - macOS laptop configuration";

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

      # Python packages overlay
      overlay = final: prev: {
        python3 = prev.python3.override {
          packageOverrides = pyFinal: pyPrev: {
            weallcode-robot = pyPrev.buildPythonPackage rec {
              pname = "weallcode_robot";
              version = "3.1.4";
              src = prev.fetchPypi {
                inherit pname version;
                hash = "sha256-f+CR7eRC3XmBlEh/gPPsC3bDCZZtTvkxaJ56ehhr/8k=";
              };
              propagatedBuildInputs = with pyPrev; [ bleak ];
              doCheck = false;
            };
          };
        };
        python3Packages = final.python3.pkgs;
      };

      pkgsFor = system:
        import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
    in {
      # Main package set
      packages = forDarwin (system:
        let pkgs = pkgsFor system;
        in {
          vscode-settings = pkgs.writeText "vscode-settings.json"
            (builtins.toJSON {
              "python.linting.enabled" = true;
              "python.linting.pylintEnabled" = true;
              "python.linting.pylintArgs" =
                [ "--disable=C0114" "--disable=C0115" "--disable=C0116" ];
              "python.formatting.provider" = "black";
              "python.formatting.blackArgs" = [ "--line-length" "120" ];
              "editor.wordWrap" = "on";
              "editor.minimap.enabled" = false;
              "editor.formatOnSave" = true;
              "security.workspace.trust.untrustedFiles" = "open";
              "workbench.startupEditor" = "newUntitledFile";
              "terminal.integrated.fontSize" = 14;
              "terminal.integrated.fontFamily" =
                "Menlo, Monaco, 'Courier New', monospace";
              "[python]" = {
                "editor.tabSize" = 4;
                "editor.insertSpaces" = true;
                "editor.detectIndentation" = false;
              };
            });

          default = pkgs.buildEnv {
            name = "weallcode-env";
            paths = with pkgs; [
              git
              direnv
              tk
              tcl
              (python3.withPackages (ps: [ ps.tkinter ps.weallcode-robot ]))
              # GUI apps
              (vscode-with-extensions.override {
                vscodeExtensions = with vscode-extensions; [
                  ms-python.python
                  ms-python.vscode-pylance
                ];
              })
              google-chrome
              dockutil
            ];
          };

          # Individual packages for flexibility
          python =
            pkgs.python3.withPackages (ps: [ ps.tkinter ps.weallcode-robot ]);
        });

      # Dev shell for testing
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
