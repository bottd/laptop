{ pkgs, ... }:
let
  python = pkgs.python3.withPackages (ps: [ ps.tkinter ps.rich ps.pip ]);
in
{
  environment.systemPackages = [ python ];
}
