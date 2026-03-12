{ ... }: {
  imports = [
    ../../modules/base.nix
  ];

  networking.hostName = "weallcode";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };
}
