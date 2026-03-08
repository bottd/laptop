{ pkgs, ... }:

{
  home.packages = [
    (pkgs.python3.withPackages (ps: [ ps.tkinter ps.weallcode-robot ]))
    pkgs.tk
    pkgs.tcl
  ];
}
