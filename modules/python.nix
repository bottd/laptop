{ pkgs, ... }:

{
  home.packages = [
    (pkgs.python3.withPackages (ps: [
      ps.tkinter
      pkgs.weallcode-robot
    ]))
    pkgs.tk
    pkgs.tcl
  ];
}
