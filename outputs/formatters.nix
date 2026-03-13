_: {
  perSystem = { config, pkgs, ... }: {
    treefmt = {
      programs = {
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
}
