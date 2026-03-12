{ inputs, ... }: {
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.pre-commit-hooks.flakeModule
    ./formatters.nix
    ./hosts.nix
  ];
}
