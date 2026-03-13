{
  description = "We All Code - NixOS laptop configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];

      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.pre-commit-hooks.flakeModule
      ];

      # Dev tooling (formatter, linters, pre-commit, dev shell)
      perSystem = { config, pkgs, ... }: {
        treefmt.programs = {
          nixpkgs-fmt.enable = true;
          deadnix = {
            enable = true;
            no-lambda-arg = true;
            no-lambda-pattern-names = true;
          };
          statix.enable = true;
          yamlfmt.enable = true;
          ruff-check.enable = true;
          ruff-format.enable = true;
        };

        formatter = config.treefmt.build.wrapper;

        pre-commit.settings.hooks.treefmt.enable = true;

        devShells.default = pkgs.mkShell {
          name = "laptop-dev";
          inherit (config.pre-commit.devShell) shellHook;
          nativeBuildInputs = with pkgs; [
            config.treefmt.build.wrapper
            git
          ] ++ config.pre-commit.settings.enabledPackages;
        };
      };

      # NixOS system configurations
      flake =
        let
          classroom = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              inputs.disko.nixosModules.disko
              inputs.home-manager.nixosModules.home-manager
              ./modules/disk.nix
              ./modules/base.nix
            ];
          };

          installer = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {
              diskoPackage = inputs.disko.packages.x86_64-linux.disko;
            };
            modules = [
              "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
              "${inputs.nixpkgs}/nixos/modules/profiles/all-hardware.nix"
              ./modules/iso.nix
            ];
          };
        in
        {
          nixosConfigurations = { inherit classroom installer; };
          packages.x86_64-linux.installer = installer.config.system.build.isoImage;
        };
    };
}
